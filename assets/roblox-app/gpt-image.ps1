# ChatGPT picture maker (fully automatic): opens the game's ChatGPT project in its own signed-in window, types the prompt,
# sends it, waits for the finished picture and saves it straight into the project. No clicking needed.
# Usage (from Claude Code or PowerShell):
#   powershell -NoProfile -File "$env:DEGEN_APP\gpt-image.ps1" -Project mythic-cube-pets -Name kappa-concept -From roblox-art-director -Prompt "<detailed prompt>"
# Prints the saved path. If the automatic way fails it falls back to: prompt pasted, lyopz clicks download, picked up from Downloads.
# Other outputs: SKIPPED / NO_IMAGE.
# Edit an existing asset: add -Ref "<current approved picture>" and a prompt like "Edit this exact picture: keep everything the same, only add ...".
param([string]$Prompt, [string]$Name = 'image', [string]$Project = '', [string]$From = 'Lead', [int]$Minutes = 15, [string]$Ref = '')
$ErrorActionPreference = 'Continue'
$RG = Join-Path $env:USERPROFILE 'RobloxGames'; $D = Join-Path $RG '.degen'
New-Item -ItemType Directory -Force -Path "$D\inbox", "$D\answers" | Out-Null
$destDir = if ($Project) { Join-Path $RG "$Project\chatgpt" } else { Join-Path $RG 'chatgpt' }
New-Item -ItemType Directory -Force -Path $destDir | Out-Null
$safe = ($Name -replace '[^\w\-]', '_')
$start = Get-Date
$port = 9333
$url = 'https://chatgpt.com/'
if ($Project) { $uf = Join-Path $RG "$Project\chatgpt-url.txt"; if (Test-Path $uf) { $u = (Get-Content $uf -TotalCount 1).Trim(); if ($u -match '^https://(chatgpt\.com|chat\.openai\.com)/') { $url = $u } } }
$edge = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe", "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
$prof = Join-Path $env:LOCALAPPDATA 'DegenChatGPT'

# Show progress in the app (Activity + Approvals card with the prompt)
$id = 'g' + (Get-Date -Format 'yyyyMMddHHmmssfff')
$item = [ordered]@{ id = $id; kind = 'chatgpt'; from = $From; at = (Get-Date -Format 'HH:mm'); name = $Name; prompt = $Prompt; images = @()
  questions = @([ordered]@{ q = 'Making this picture in ChatGPT'; h = 'ChatGPT'; multi = $false; options = @() }) }
[IO.File]::WriteAllText("$D\inbox\$id.json", ($item | ConvertTo-Json -Depth 8 -Compress), (New-Object Text.UTF8Encoding $false))
function Done($out) { Remove-Item "$D\inbox\$id.json" -Force -ErrorAction SilentlyContinue; $out; exit 0 }

# ---------- Chrome DevTools helpers ----------
function Get-Targets { try { Invoke-RestMethod "http://127.0.0.1:$port/json" -TimeoutSec 2 } catch { $null } }
$ws = $null; $msgId = 0
function Cdp-Open($wsUrl) {
  $script:ws = New-Object Net.WebSockets.ClientWebSocket
  $script:ws.Options.KeepAliveInterval = [TimeSpan]::FromSeconds(20)
  $script:ws.ConnectAsync([Uri]$wsUrl, [Threading.CancellationToken]::None).Wait(8000) | Out-Null
  return ($script:ws.State -eq 'Open')
}
function Cdp($method, $params) {
  $script:msgId++; $myId = $script:msgId
  $json = @{ id = $myId; method = $method; params = $params } | ConvertTo-Json -Depth 10 -Compress
  $bytes = [Text.Encoding]::UTF8.GetBytes($json)
  $script:ws.SendAsync([ArraySegment[byte]]::new($bytes), 'Text', $true, [Threading.CancellationToken]::None).Wait(10000) | Out-Null
  $buf = New-Object byte[] 1048576
  while ($true) {
    $ms = New-Object IO.MemoryStream
    do {
      $t = $script:ws.ReceiveAsync([ArraySegment[byte]]::new($buf), [Threading.CancellationToken]::None)
      if (-not $t.Wait(120000)) { return $null }
      $ms.Write($buf, 0, $t.Result.Count)
    } while (-not $t.Result.EndOfMessage)
    $r = [Text.Encoding]::UTF8.GetString($ms.ToArray()) | ConvertFrom-Json
    if ($r.id -eq $myId) { return $r }
  }
}
function Js($code) {
  $r = Cdp 'Runtime.evaluate' @{ expression = $code; awaitPromise = $true; returnByValue = $true }
  if ($r -and $r.result -and $r.result.result) { return $r.result.result.value } ; return $null
}

# ---------- 1) open ChatGPT with remote control on ----------
$targets = Get-Targets
if (-not $targets) {
  # a ChatGPT window opened the old way (without remote control) blocks it: close those first
  $old = @(Get-CimInstance Win32_Process -Filter "Name='msedge.exe'" | Where-Object { $_.CommandLine -like '*DegenChatGPT*' })
  if ($old.Count) { $old | ForEach-Object { $p = Get-Process -Id $_.ProcessId -ErrorAction SilentlyContinue; if ($p -and $p.MainWindowHandle -ne 0) { [void]$p.CloseMainWindow() } }
    Start-Sleep -Seconds 4   # let it close cleanly so the sign-in is kept
    @(Get-CimInstance Win32_Process -Filter "Name='msedge.exe'" | Where-Object { $_.CommandLine -like '*DegenChatGPT*' }) | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue } }
  Write-Host '[1/4] Opening ChatGPT...'
  if ($edge) { Start-Process $edge -ArgumentList @("--app=$url", "--user-data-dir=$prof", "--remote-debugging-port=$port", '--window-size=1100,900', '--no-first-run') }
  for ($i = 0; $i -lt 20 -and -not $targets; $i++) { Start-Sleep -Milliseconds 700; $targets = Get-Targets }
}
if (-not $targets) { Write-Host 'Could not open ChatGPT with remote control.' } else { Write-Host '[2/4] ChatGPT open' }
$auto = $false
$node = (Get-Command node -ErrorAction SilentlyContinue).Source
if ($targets -and $node) {
  $app = $PSScriptRoot; $nm = Join-Path $app 'node_modules\playwright-core'
  if (-not (Test-Path $nm)) { Write-Host '  first run: installing the browser helper (one time)...'; Push-Location $app; npm install --no-save --no-audit --no-fund playwright-core@1.48.2 2>&1 | Out-Null; Pop-Location }
  $pf = Join-Path $env:TEMP ('gpt-prompt-' + $id + '.txt'); [IO.File]::WriteAllText($pf, $Prompt, (New-Object Text.UTF8Encoding $false))
  $outBase = Join-Path $destDir ($safe + '-' + (Get-Date -Format 'HHmmss'))
  $saved = & $node (Join-Path $app 'gpt-image.mjs') $pf $outBase $url $Ref | Select-Object -Last 1
  Remove-Item $pf -Force -ErrorAction SilentlyContinue
  if ($saved -and (Test-Path $saved)) { Done $saved }
  $auto = $true   # prompt was (probably) sent; fall back to the download pick-up below
} elseif (-not $node) { Write-Host 'Node.js not found - using the simple way.' }

# ---------- fallback: paste + lyopz clicks download ----------
if (-not $auto) {
  Set-Clipboard -Value $Prompt
  if (-not $page) { if ($edge) { Start-Process $edge -ArgumentList @("--app=$url", "--user-data-dir=$prof", '--window-size=1100,900', '--no-first-run') } else { Start-Process $url }; Start-Sleep -Seconds 9 }
  $sh = New-Object -ComObject WScript.Shell
  if ($sh.AppActivate('ChatGPT')) { Start-Sleep -Milliseconds 600; $sh.SendKeys('^v'); Start-Sleep -Milliseconds 700; $sh.SendKeys('{ENTER}') }
}
Write-Output 'Automatic save did not finish - click download on the picture in ChatGPT; it will be picked up from Downloads.'
$dl = Join-Path $env:USERPROFILE 'Downloads'; $ans = "$D\answers\$id.json"; $until = (Get-Date).AddMinutes(30)
while ((Get-Date) -lt $until) {
  $found = Get-ChildItem $dl -File | Where-Object { $_.Extension -in '.png', '.jpg', '.jpeg', '.webp' -and $_.LastWriteTime -gt $start -and $_.Length -gt 10kb } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($found) { Start-Sleep -Milliseconds 800; $dest = Join-Path $destDir ($safe + '-' + (Get-Date -Format 'HHmmss') + $found.Extension); Copy-Item $found.FullName $dest -Force; Done $dest }
  if (Test-Path $ans) { $a = [IO.File]::ReadAllText($ans) | ConvertFrom-Json; Remove-Item $ans -Force; if ([string]$a.answer -like 'skip*') { Done 'SKIPPED' } }
  Start-Sleep -Seconds 1
}
Done 'NO_IMAGE'
