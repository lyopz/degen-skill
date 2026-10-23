# Degen Roblox local server (http://localhost:7777). Lets the app talk to the Roblox Lead window both ways:
#  - GET  /api/state          activity feed, who is working, pending approvals/questions, projects
#  - POST /api/answer         {id, answer}  -> answers a question / approval the Lead is waiting on
#  - POST /api/task           {brief}       -> opens a Roblox Lead window with that task
#  - GET  /f?p=<path>         images/files from ~/RobloxGames only (for approvals + project assets)
# Runs hidden; started by launch.ps1. Only listens on localhost.
$ErrorActionPreference = 'SilentlyContinue'
$app  = $PSScriptRoot
$RG   = Join-Path $env:USERPROFILE 'RobloxGames'
$D    = Join-Path $RG '.degen'
foreach ($p in @($RG, $D, "$D\inbox", "$D\answers")) { New-Item -ItemType Directory -Force -Path $p | Out-Null }
$port = 7777
$http = New-Object Net.HttpListener
$http.Prefixes.Add("http://localhost:$port/")
try { $http.Start() } catch { exit 0 }   # already running
$MIME = @{ '.html'='text/html; charset=utf-8'; '.js'='text/javascript; charset=utf-8'; '.css'='text/css'; '.png'='image/png'; '.jpg'='image/jpeg'; '.jpeg'='image/jpeg'; '.webp'='image/webp'; '.gif'='image/gif'; '.ico'='image/x-icon'; '.json'='application/json'; '.md'='text/plain; charset=utf-8'; '.glb'='model/gltf-binary'; '.svg'='image/svg+xml'; '.mp3'='audio/mpeg'; '.wav'='audio/wav' }
$utf8 = New-Object Text.UTF8Encoding $false

function Send($ctx, $code, $type, [byte[]]$bytes) {
  $r = $ctx.Response; $r.StatusCode = $code; $r.ContentType = $type
  $r.Headers['Cache-Control'] = 'no-store'
  $r.ContentLength64 = $bytes.Length; $r.OutputStream.Write($bytes, 0, $bytes.Length); $r.OutputStream.Close()
}
function SendJson($ctx, $obj) { Send $ctx 200 'application/json; charset=utf-8' ($utf8.GetBytes(($obj | ConvertTo-Json -Depth 8 -Compress))) }
function ReadBody($ctx) { $sr = New-Object IO.StreamReader($ctx.Request.InputStream, [Text.Encoding]::UTF8); $t = $sr.ReadToEnd(); $sr.Close(); if ($t) { $t | ConvertFrom-Json } }
function Under($path, $root) { try { $f = [IO.Path]::GetFullPath($path); return $f.StartsWith([IO.Path]::GetFullPath($root), [StringComparison]::OrdinalIgnoreCase) } catch { return $false } }

function Get-Projects {
  foreach ($d in Get-ChildItem $RG -Directory | Where-Object { $_.Name -notlike '.*' -and $_.Name -ne 'imports' } | Sort-Object LastWriteTime -Descending) {
    $files = @(Get-ChildItem $d.FullName -Recurse -File | Where-Object { $_.FullName -notmatch '\\(checks|tex)\\' })
    $imgs  = @($files | Where-Object { $_.Extension -in '.png','.jpg','.jpeg','.webp' } | Sort-Object LastWriteTime -Descending | Select-Object -First 40 | ForEach-Object { $_.FullName })
    $models = @($files | Where-Object { $_.Extension -in '.glb','.fbx','.rbxm','.rbxmx' } | ForEach-Object { $_.FullName.Substring($d.FullName.Length + 1) })
    $docs  = @($files | Where-Object { $_.Extension -eq '.md' } | ForEach-Object { $_.FullName.Substring($d.FullName.Length + 1) })
    $ho = Join-Path $d.FullName 'HANDOFF.md'
    [ordered]@{ n = $d.Name; path = $d.FullName; updated = $d.LastWriteTime.ToString('yyyy-MM-dd HH:mm'); images = $imgs; models = $models; docs = $docs
                handoff = $(if (Test-Path $ho) { [IO.File]::ReadAllText($ho) } else { '' }) }
  }
}
function Get-State {
  $act = Join-Path $D 'activity.json'
  $a = if (Test-Path $act) { [IO.File]::ReadAllText($act) | ConvertFrom-Json } else { $null }
  $inbox = @(Get-ChildItem "$D\inbox" -Filter *.json | Sort-Object LastWriteTime | ForEach-Object { [IO.File]::ReadAllText($_.FullName) | ConvertFrom-Json })
  [ordered]@{ lines = @(if ($a) { $a.lines }); active = $(if ($a) { $a.active } else { @{} }); status = $(if ($a) { $a.status } else { "idle" }); inbox = $inbox; t = (Get-Date -Format 'HH:mm:ss') }
}

$projCache = $null; $projAt = [datetime]::MinValue
while ($http.IsListening) {
  [IO.File]::WriteAllText("$D\server.alive", (Get-Date).ToString('o'))
  $task = $http.GetContextAsync()
  while (-not $task.AsyncWaitHandle.WaitOne(3000)) { [IO.File]::WriteAllText("$D\server.alive", (Get-Date).ToString('o')) }
  $ctx = $task.Result
  try {
    $u = $ctx.Request.Url; $path = $u.AbsolutePath
    if ($path -eq '/api/state') { SendJson $ctx (Get-State) }
    elseif ($path -eq '/api/projects') {
      if (((Get-Date) - $projAt).TotalSeconds -gt 10) { $projCache = @(Get-Projects); $projAt = Get-Date }
      SendJson $ctx @{ projects = $projCache } }
    elseif ($path -eq '/api/answer' -and $ctx.Request.HttpMethod -eq 'POST') {
      $b = ReadBody $ctx; $id = ($b.id -replace '[^\w\-]', '')
      if ($id) {
        [IO.File]::WriteAllText("$D\answers\$id.json", (@{ id = $id; answer = $b.answer; at = (Get-Date).ToString('o') } | ConvertTo-Json -Compress), $utf8)
        Remove-Item "$D\inbox\$id.json" -Force
      }
      SendJson $ctx @{ ok = [bool]$id } }
    elseif ($path -eq '/api/upload' -and $ctx.Request.HttpMethod -eq 'POST') {
      $name = [Uri]::UnescapeDataString(($u.Query -replace '^\?name=', '')) -replace '[^\w\.\- ]', '_'
      $dir = Join-Path $RG ('imports\' + (Get-Date -Format 'yyyy-MM-dd')); New-Item -ItemType Directory -Force -Path $dir | Out-Null
      $dest = Join-Path $dir $name; $fs = [IO.File]::Create($dest); $ctx.Request.InputStream.CopyTo($fs); $fs.Close()
      SendJson $ctx @{ ok = $true; path = $dest } }
    elseif ($path -eq '/api/task' -and $ctx.Request.HttpMethod -eq 'POST') {
      $b = ReadBody $ctx
      $f = Join-Path $env:TEMP ('degen-roblox-task-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.md')
      [IO.File]::WriteAllText($f, $(if ($b.brief) { [string]$b.brief } else { '/roblox' }), $utf8)
      Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $app 'lead-start.ps1'), $f)
      SendJson $ctx @{ ok = $true } }
    elseif ($path -eq '/f') {
      $p = [Uri]::UnescapeDataString(($u.Query -replace '^\?p=', ''))
      if ((Under $p $RG) -and (Test-Path $p -PathType Leaf)) { $ext = [IO.Path]::GetExtension($p).ToLower(); Send $ctx 200 ($(if ($MIME[$ext]) { $MIME[$ext] } else { 'application/octet-stream' })) ([IO.File]::ReadAllBytes($p)) }
      else { Send $ctx 404 'text/plain' ($utf8.GetBytes('not found')) } }
    else {
      $rel = if ($path -eq '/') { 'index.html' } else { $path.TrimStart('/') -replace '/', '\' }
      $file = Join-Path $app $rel
      if ((Under $file $app) -and (Test-Path $file -PathType Leaf)) { $ext = [IO.Path]::GetExtension($file).ToLower(); Send $ctx 200 ($(if ($MIME[$ext]) { $MIME[$ext] } else { 'application/octet-stream' })) ([IO.File]::ReadAllBytes($file)) }
      else { Send $ctx 404 'text/plain' ($utf8.GetBytes('not found')) }
    }
  } catch { try { Send $ctx 500 'text/plain' ($utf8.GetBytes([string]$_)) } catch {} }
}
