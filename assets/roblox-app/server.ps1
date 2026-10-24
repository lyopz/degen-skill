# Degen Roblox local server (http://localhost:7777). Lets the app talk to the Roblox Lead window both ways:
#  - GET  /api/state          activity feed, who is working, pending approvals/questions, projects
#  - POST /api/answer         {id, answer}  -> answers a question / approval the Lead is waiting on
#  - POST /api/task           {brief}       -> opens a Roblox Lead window with that task
#  - POST /api/resume         {project}     -> "Continue last task": reopens that project's last Lead conversation
#                                              (session ids saved by activity-hook.ps1 in .degen/sessions.json), else starts from its HANDOFF.md
#  - POST /api/subproject   {game, name, task} -> new project inside a game: ~/RobloxGames/<game>/projects/<name>/ with its own HANDOFF.md
#  - GET  /api/update       in-app update state (update.ps1 writes .degen/update.json)
#  - POST /api/update       {check:true} -> looks on GitHub for updates; {} -> pulls them, rebuilds the app data, restarts this server if it changed
#  - GET  /f?p=<path>         images/files from ~/RobloxGames or the repo's styles/ folder only
#  - GET  /api/styles         saved styles ("Save for later" tab), from <repo>/styles/<name>/
#  - GET  /api/style-draft?project=<name>  that project's bible + rated prompts + pictures, to pre-fill a save
#  - POST /api/styles/save    {name, project, notes, bible, prompts, images[]} -> writes styles/<slug>/ and pushes to GitHub
#  - GET  /api/watch          "Watch me play" recorder state + past sessions (~/RobloxGames/.degen/watch/, local only)
#  - POST /api/watch/start    {game} -> starts watch-play.ps1 hidden;  /api/watch/stop -> stops it
#  - POST /api/watch/note     {text, kind} -> adds what lyopz said/typed to the running session's notes.jsonl
# Runs hidden; started by launch.ps1. Only listens on localhost.
$ErrorActionPreference = 'SilentlyContinue'
$app  = $PSScriptRoot
$repo = Split-Path -Parent (Split-Path -Parent $app)
$ST   = Join-Path $repo 'styles'
$RG   = Join-Path $env:USERPROFILE 'RobloxGames'
$D    = Join-Path $RG '.degen'
foreach ($p in @($RG, $D, "$D\inbox", "$D\answers", $ST)) { New-Item -ItemType Directory -Force -Path $p | Out-Null }
$port = 7777
$http = New-Object Net.HttpListener
$http.Prefixes.Add("http://localhost:$port/")
try { $http.Start() } catch { exit 0 }   # already running
# launch.ps1 restarts the server when this file changed since it started (after a git pull)
[IO.File]::WriteAllText("$D\server.ver", [string](Get-Item $PSCommandPath).LastWriteTimeUtc.Ticks)
$MIME = @{ '.html'='text/html; charset=utf-8'; '.js'='text/javascript; charset=utf-8'; '.css'='text/css'; '.png'='image/png'; '.jpg'='image/jpeg'; '.jpeg'='image/jpeg'; '.webp'='image/webp'; '.gif'='image/gif'; '.ico'='image/x-icon'; '.json'='application/json'; '.md'='text/plain; charset=utf-8'; '.glb'='model/gltf-binary'; '.svg'='image/svg+xml'; '.mp3'='audio/mpeg'; '.wav'='audio/wav' }
$utf8 = New-Object Text.UTF8Encoding $false

function Send($ctx, $code, $type, [byte[]]$bytes) {
  $r = $ctx.Response; $r.StatusCode = $code; $r.ContentType = $type
  $r.Headers['Cache-Control'] = 'no-store'
  $r.ContentLength64 = $bytes.Length; $r.OutputStream.Write($bytes, 0, $bytes.Length); $r.OutputStream.Close()
}
function SendJson($ctx, $obj) { Send $ctx 200 'application/json; charset=utf-8' ($utf8.GetBytes(($obj | ConvertTo-Json -Depth 8 -Compress))) }
function ReadBody($ctx) { $sr = New-Object IO.StreamReader($ctx.Request.InputStream, [Text.Encoding]::UTF8); $t = $sr.ReadToEnd(); $sr.Close(); if ($t) { $t | ConvertFrom-Json } }
function Under($path, $root) { try { $f = [IO.Path]::GetFullPath($path); $r = [IO.Path]::GetFullPath($root).TrimEnd('\') + '\'; return $f.StartsWith($r, [StringComparison]::OrdinalIgnoreCase) } catch { return $false } }

# A project is a game folder (~/RobloxGames/<game>) or a project inside one (<game>/projects/<name>, same place + style bible).
# Returns its full path, or $null if the name is not a real project folder.
function ProjDir($rel) {
  $r = ([string]$rel -replace '\\', '/').Trim('/')
  if ($r -notmatch '^[\w\-\. ]+(/projects/[\w\-\.]+)?$' -or $r -match '(^|/)\.') { return $null }
  $p = Join-Path $RG ($r -replace '/', '\')
  if ((Test-Path $p -PathType Container) -and (Under $p $RG)) { return $p } else { return $null }
}
function Get-LastTasks { $f = Join-Path $D 'sessions.json'; if (Test-Path $f) { ([IO.File]::ReadAllText($f) | ConvertFrom-Json).p } }
function Get-Projects {
  $last = Get-LastTasks
  foreach ($d in Get-ChildItem $RG -Directory | Where-Object { $_.Name -notlike '.*' -and $_.Name -ne 'imports' } | Sort-Object LastWriteTime -Descending) {
    $files = @(Get-ChildItem $d.FullName -Recurse -File | Where-Object { $_.FullName -notmatch '\\(checks|tex)\\' })
    $imgs  = @($files | Where-Object { $_.Extension -in '.png','.jpg','.jpeg','.webp' } | Sort-Object LastWriteTime -Descending | Select-Object -First 40 | ForEach-Object { $_.FullName })
    $models = @($files | Where-Object { $_.Extension -in '.glb','.fbx','.rbxm','.rbxmx' } | ForEach-Object { $_.FullName.Substring($d.FullName.Length + 1) })
    $docs  = @($files | Where-Object { $_.Extension -eq '.md' } | ForEach-Object { $_.FullName.Substring($d.FullName.Length + 1) })
    $ho = Join-Path $d.FullName 'HANDOFF.md'; $cu = Join-Path $d.FullName 'chatgpt-url.txt'
    [ordered]@{ n = $d.Name; path = $d.FullName; updated = $d.LastWriteTime.ToString('yyyy-MM-dd HH:mm'); images = $imgs; models = $models; docs = $docs
                chatgpt = $(if (Test-Path $cu) { (Get-Content $cu -TotalCount 1) } else { '' }); handoff = $(if (Test-Path $ho) { [IO.File]::ReadAllText($ho) } else { '' })
                last = $(if ($last -and $last.($d.Name)) { $l = $last.($d.Name); [ordered]@{ at = $l.at; task = $l.task } } else { $null })
                subs = @(Get-Subs $d $last) }
  }
}
function Get-Subs($game, $last) {
  foreach ($s in @(Get-ChildItem (Join-Path $game.FullName 'projects') -Directory | Sort-Object LastWriteTime -Descending)) {
    $rel = "$($game.Name)/projects/$($s.Name)"; $ho = Join-Path $s.FullName 'HANDOFF.md'
    $imgs = @(Get-ChildItem $s.FullName -Recurse -File | Where-Object { $_.Extension -in '.png','.jpg','.jpeg','.webp' } | Sort-Object LastWriteTime -Descending | ForEach-Object { $_.FullName })
    [ordered]@{ n = $s.Name; rel = $rel; game = $game.Name; path = $s.FullName; updated = $s.LastWriteTime.ToString('yyyy-MM-dd HH:mm'); images = $imgs
                handoff = $(if (Test-Path $ho) { [IO.File]::ReadAllText($ho) } else { '' })
                last = $(if ($last -and $last.$rel) { $l = $last.$rel; [ordered]@{ at = $l.at; task = $l.task } } else { $null }) }
  }
}
function New-Sub($b) {
  $game = ([string]$b.game -replace '[^\w\-\. ]', '') -replace '^\.+', ''; $gdir = ProjDir $game
  if (-not $game -or -not $gdir) { return @{ ok = $false; msg = 'Pick a game first' } }
  $name = ((([string]$b.name).Trim() -replace '\s+', '-') -replace '[^\w\-]', '').Trim('-')
  if (-not $name) { return @{ ok = $false; msg = 'Give it a name' } }
  $dir = Join-Path $gdir "projects\$name"; $isNew = -not (Test-Path $dir)
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  if ($isNew) {
    $md = "# $name`n`n_Project inside $game (same Studio place, same style: ../../art-style.md). Started $(Get-Date -Format 'yyyy-MM-dd HH:mm') from the app._`n`n## Goal`n`n$(if ($b.task) { [string]$b.task } else { '(not written yet)' })`n`n## Done`n`n(nothing yet)`n`n## Next`n`n- Start on the goal above`n"
    [IO.File]::WriteAllText((Join-Path $dir 'HANDOFF.md'), $md, $utf8)
  }
  @{ ok = $true; rel = "$((Get-Item $gdir).Name)/projects/$name"; isNew = $isNew }
}
function Get-Update {
  $f = Join-Path $D 'update.json'
  $u = if (Test-Path $f) { [IO.File]::ReadAllText($f) | ConvertFrom-Json } else { [pscustomobject]@{ state = 'none'; behind = 0 } }
  # a check or update that died half way: don't look busy forever
  if ($u.state -in 'checking','updating' -and ((Get-Date) - (Get-Item $f).LastWriteTime).TotalMinutes -gt 3) { $u.state = 'error'; $u | Add-Member -NotePropertyName msg -NotePropertyValue 'Update timed out, try again' -Force }
  $u
}
# Saved styles (lyopz names them in the app's "Save for later" tab). The ONLY game-derived content that goes to the repo,
# and only what he picked + reviewed in that tab.
function Slug($t) { ((([string]$t).ToLower() -replace '[^a-z0-9]+', '-').Trim('-')) }
function Get-Styles {
  foreach ($d in Get-ChildItem $ST -Directory | Sort-Object LastWriteTime -Descending) {
    $f = Join-Path $d.FullName 'style.md'; if (-not (Test-Path $f)) { continue }
    $t = [IO.File]::ReadAllText($f); $n = if ($t -match '(?m)^# (.+)$') { $Matches[1].Trim() } else { $d.Name }
    $pf = Join-Path $d.FullName 'prompts.md'
    [ordered]@{ slug = $d.Name; n = $n; updated = $d.LastWriteTime.ToString('yyyy-MM-dd'); text = $t; prompts = $(if (Test-Path $pf) { [IO.File]::ReadAllText($pf) } else { '' })
                images = @(Get-ChildItem $d.FullName -File | Where-Object { $_.Extension -in '.png','.jpg','.jpeg','.webp' } | Sort-Object Name | ForEach-Object { $_.FullName }) }
  }
}
function Get-StyleDraft($project) {
  $pdir = Join-Path $RG (([string]$project -replace '[^\w\-\. ]', '') -replace '^\.+', '')
  if (-not $project -or -not (Test-Path $pdir) -or (Under $RG $pdir)) { return @{ ok = $false } }
  $bf = Join-Path $pdir 'art-style.md'
  $fb = @(Get-ChildItem $pdir -Recurse -Filter feedback.jsonl | ForEach-Object { Get-Content $_.FullName -Encoding UTF8 } | Where-Object { $_ } | ForEach-Object { try { $_ | ConvertFrom-Json } catch {} })
  $prompts = @($fb | Where-Object { $_.prompt } | ForEach-Object { [ordered]@{ name = $_.name; rating = $_.rating; answer = $_.answer; prompt = $_.prompt; image = $_.image } })
  $imgs = @(Get-ChildItem $pdir -Recurse -File | Where-Object { $_.Extension -in '.png','.jpg','.jpeg','.webp' -and $_.FullName -notmatch '\\(checks|tex)\\' } | Sort-Object LastWriteTime -Descending | Select-Object -First 60 | ForEach-Object { $_.FullName })
  [ordered]@{ ok = $true; bible = $(if (Test-Path $bf) { [IO.File]::ReadAllText($bf) } else { '' }); prompts = $prompts; images = $imgs }
}
function Save-Style($b) {
  $name = ([string]$b.name).Trim(); $slug = Slug $name
  if (-not $slug) { return @{ ok = $false; msg = 'Give the style a name' } }
  $proj = ([string]$b.project -replace '[^\w\-\. ]', '') -replace '^\.+', ''; $pdir = Join-Path $RG $proj
  if (-not $proj -or -not (Test-Path $pdir)) { return @{ ok = $false; msg = 'Pick a project first' } }
  $dir = Join-Path $ST $slug
  if (Test-Path $dir) { Get-ChildItem $dir -File | Remove-Item -Force }   # same name = update it
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  $pics = @(); $i = 0
  foreach ($p in @($b.images)) {
    if ($i -ge 8) { break }
    if ((Under $p $pdir) -and (Test-Path $p -PathType Leaf)) { $i++; $dest = "pic-$i" + [IO.Path]::GetExtension($p).ToLower(); Copy-Item $p (Join-Path $dir $dest) -Force; $pics += $dest }
  }
  $md = "# $name`n`n_Saved $(Get-Date -Format 'yyyy-MM-dd') from the Degen Roblox app (Save for later). Named by lyopz._`n`n"
  if ($b.notes) { $md += "## What lyopz likes about it`n`n$([string]$b.notes)`n`n" }
  if ($pics.Count) { $md += "## Pictures`n`n" + (($pics | ForEach-Object { "![]($_)" }) -join "`n") + "`n`n" }
  if ($b.bible) { $md += "## Style (look, shapes, palette, rules)`n`n$([string]$b.bible)`n" }
  [IO.File]::WriteAllText((Join-Path $dir 'style.md'), $md, $utf8)
  if ($b.prompts) { [IO.File]::WriteAllText((Join-Path $dir 'prompts.md'), "# Prompts used - $name`n`n$([string]$b.prompts)`n", $utf8) }
  # push only this style folder
  $env:GIT_TERMINAL_PROMPT = '0'
  $rel = "styles/$slug"
  git -C $repo add -A -- $rel 2>&1 | Out-Null
  $c = git -C $repo commit -m "Save style: $name" -- $rel 2>&1 | Out-String
  $out = git -C $repo push 2>&1 | Out-String
  if ($LASTEXITCODE -ne 0) { git -C $repo pull --rebase --autostash --quiet 2>&1 | Out-Null; $out = git -C $repo push 2>&1 | Out-String }
  $pushed = ($LASTEXITCODE -eq 0)
  @{ ok = $true; slug = $slug; pushed = $pushed; msg = $(if ($pushed) { 'Saved and pushed to GitHub' } else { 'Saved on this PC, push failed: ' + $out.Trim() }) }
}

# "Watch me play" (watch-play.ps1): screenshots + lyopz's notes while he plays, for roblox-game-study to learn from.
$WD = Join-Path $D 'watch'
function Get-WatchNow {
  $f = Join-Path $D 'watch.json'; if (-not (Test-Path $f)) { return $null }
  $w = [IO.File]::ReadAllText($f) | ConvertFrom-Json
  if ($w.running -and -not (Get-Process -Id $w.pid -ErrorAction SilentlyContinue)) { $w.running = $false }
  $w
}
function Get-Watch {
  $sessions = foreach ($d in @(Get-ChildItem $WD -Directory | Sort-Object Name -Descending | Select-Object -First 12)) {
    $sj = Join-Path $d.FullName 'session.json'; $s = if (Test-Path $sj) { [IO.File]::ReadAllText($sj) | ConvertFrom-Json } else { $null }
    $nf = Join-Path $d.FullName 'notes.jsonl'; $notes = if (Test-Path $nf) { @(Get-Content $nf -Encoding UTF8 | Where-Object { $_ -notmatch '"kind":"end"' }).Count } else { 0 }
    $pic = Get-ChildItem (Join-Path $d.FullName 'sheets') -Filter *.jpg | Sort-Object Name | Select-Object -First 1
    if (-not $pic) { $pic = Get-ChildItem $d.FullName -Filter *.jpg | Sort-Object Name | Select-Object -Last 1 }
    [ordered]@{ n = $d.Name; path = $d.FullName; game = $(if ($s) { $s.game } else { $d.Name }); shots = @(Get-ChildItem $d.FullName -Filter *.jpg).Count
                notes = $notes; learned = (Test-Path (Join-Path $d.FullName 'learned.md')); pic = $(if ($pic) { $pic.FullName } else { '' }) }
  }
  @{ now = (Get-WatchNow); sessions = @($sessions) }
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
    elseif ($path -eq '/api/styles') { SendJson $ctx @{ styles = @(Get-Styles) } }
    elseif ($path -eq '/api/style-draft') { SendJson $ctx (Get-StyleDraft ([Uri]::UnescapeDataString(($u.Query -replace '^\?project=', '')))) }
    elseif ($path -eq '/api/styles/save' -and $ctx.Request.HttpMethod -eq 'POST') { SendJson $ctx (Save-Style (ReadBody $ctx)) }
    elseif ($path -eq '/api/answer' -and $ctx.Request.HttpMethod -eq 'POST') {
      $b = ReadBody $ctx; $id = ($b.id -replace '[^\w\-]', '')
      if ($id) {
        [IO.File]::WriteAllText("$D\answers\$id.json", (@{ id = $id; answer = $b.answer; at = (Get-Date).ToString('o') } | ConvertTo-Json -Compress), $utf8)
        Remove-Item "$D\inbox\$id.json" -Force
      }
      SendJson $ctx @{ ok = [bool]$id } }
    elseif ($path -eq '/api/watch') { SendJson $ctx (Get-Watch) }
    elseif ($path -eq '/api/watch/start' -and $ctx.Request.HttpMethod -eq 'POST') {
      $b = ReadBody $ctx; $w = Get-WatchNow
      if (-not ($w -and $w.running)) {
        $game = (([string]$b.game -replace '[^\w\- ]', '').Trim()); if (-not $game) { $game = 'roblox' }
        Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', ('"' + (Join-Path $app 'watch-play.ps1') + '"'), '-Game', ('"' + $game + '"'))
        Start-Sleep -Milliseconds 1500
      }
      SendJson $ctx (Get-Watch) }
    elseif ($path -eq '/api/watch/stop' -and $ctx.Request.HttpMethod -eq 'POST') {
      [IO.File]::WriteAllText((Join-Path $D 'watch.stop'), 'stop', $utf8)
      SendJson $ctx @{ ok = $true } }
    elseif ($path -eq '/api/watch/note' -and $ctx.Request.HttpMethod -eq 'POST') {
      $b = ReadBody $ctx; $w = Get-WatchNow; $ok = $false
      if ($w -and $w.running -and [string]$b.text -and (Under $w.dir $WD)) {
        $l = [ordered]@{ s = [int]((Get-Date) - [datetime]$w.started).TotalSeconds; at = (Get-Date -Format 'HH:mm:ss'); kind = $(if ($b.kind -eq 'say') { 'say' } else { 'note' }); text = [string]$b.text; shot = $null } | ConvertTo-Json -Compress
        [IO.File]::AppendAllText((Join-Path $w.dir 'notes.jsonl'), "$l`n", $utf8); $ok = $true
      }
      SendJson $ctx @{ ok = $ok } }
    elseif ($path -eq '/api/chatgpt-url' -and $ctx.Request.HttpMethod -eq 'POST') {
      $b = ReadBody $ctx; $pdir = Join-Path $RG ([string]$b.project -replace '[^\w\-\. ]', '')
      $ok = (Test-Path $pdir) -and ([string]$b.url -match '^https://(chatgpt\.com|chat\.openai\.com)/')
      if ($ok) { [IO.File]::WriteAllText((Join-Path $pdir 'chatgpt-url.txt'), [string]$b.url, $utf8); $projAt = [datetime]::MinValue }
      SendJson $ctx @{ ok = $ok } }
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
    elseif ($path -eq '/api/resume' -and $ctx.Request.HttpMethod -eq 'POST') {
      $b = ReadBody $ctx; $proj = ([string]$b.project -replace '\\', '/').Trim('/'); $pdir = ProjDir $proj
      if ($pdir) {
        $l = (Get-LastTasks).$proj; $sid = if ($l -and ([string]$l.id -match '^[\w\-]+$')) { [string]$l.id } else { '' }
        $where = if ($proj -match '^([^/]+)/projects/') { "Project folder: ~/RobloxGames/$proj - a project inside the game $($Matches[1]) (same Studio place). Read ~/RobloxGames/$($Matches[1])/HANDOFF.md and art-style.md first, then this folder's HANDOFF.md; save new assets for it in this folder." } else { "Project folder: ~/RobloxGames/$proj - read its HANDOFF.md and art-style.md first; save new assets there." }
        $brief = $(if ($l.task) { "Task: $($l.task)`n" } else { "Task: carry on with the next step in HANDOFF.md`n" }) + "$where`nThis is this project's last task: carry on from where it stopped (HANDOFF.md says what is done). If it is already finished, do HANDOFF.md 'Next'."
        $f = Join-Path $env:TEMP ('degen-roblox-task-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.md'); [IO.File]::WriteAllText($f, $brief, $utf8)
        $al = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"' + (Join-Path $app 'lead-start.ps1') + '"'), ('"' + $f + '"')); if ($sid) { $al += @('-Resume', $sid) }
        Start-Process powershell.exe -WindowStyle Hidden -ArgumentList $al
        SendJson $ctx @{ ok = $true; resumed = [bool]$sid }
      } else { SendJson $ctx @{ ok = $false } } }
    elseif ($path -eq '/api/subproject' -and $ctx.Request.HttpMethod -eq 'POST') { $r = New-Sub (ReadBody $ctx); $projAt = [datetime]::MinValue; SendJson $ctx $r }
    elseif ($path -eq '/api/update' -and $ctx.Request.HttpMethod -eq 'POST') {
      $b = ReadBody $ctx; $u = Get-Update
      if ($u.state -notin 'checking','updating') {
        $al = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', ('"' + (Join-Path $app 'update.ps1') + '"')); if ($b.check) { $al += '-Check' }
        [IO.File]::WriteAllText((Join-Path $D 'update.json'), (@{ state = $(if ($b.check) { 'checking' } else { 'updating' }); behind = [int]$u.behind; at = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') } | ConvertTo-Json -Compress), $utf8)
        Start-Process powershell.exe -WindowStyle Hidden -ArgumentList $al
      }
      SendJson $ctx (Get-Update) }
    elseif ($path -eq '/api/update') { SendJson $ctx (Get-Update) }
    elseif ($path -eq '/f') {
      $p = [Uri]::UnescapeDataString(($u.Query -replace '^\?p=', ''))
      if (((Under $p $RG) -or (Under $p $ST)) -and (Test-Path $p -PathType Leaf)) { $ext = [IO.Path]::GetExtension($p).ToLower(); Send $ctx 200 ($(if ($MIME[$ext]) { $MIME[$ext] } else { 'application/octet-stream' })) ([IO.File]::ReadAllBytes($p)) }
      else { Send $ctx 404 'text/plain' ($utf8.GetBytes('not found')) } }
    else {
      $rel = if ($path -eq '/') { 'index.html' } else { $path.TrimStart('/') -replace '/', '\' }
      $file = Join-Path $app $rel
      if ((Under $file $app) -and (Test-Path $file -PathType Leaf)) { $ext = [IO.Path]::GetExtension($file).ToLower(); Send $ctx 200 ($(if ($MIME[$ext]) { $MIME[$ext] } else { 'application/octet-stream' })) ([IO.File]::ReadAllBytes($file)) }
      else { Send $ctx 404 'text/plain' ($utf8.GetBytes('not found')) }
    }
  } catch { try { Send $ctx 500 'text/plain' ($utf8.GetBytes([string]$_)) } catch {} }
}
