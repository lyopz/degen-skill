# Claude Code status line for the Roblox Lead. Claude Code hands it the session's data (incl. lyopz's plan usage:
# rate_limits.five_hour / seven_day used_percentage + resets_at). It saves that for usage-hook.ps1 and prints one short line.
$ErrorActionPreference = 'SilentlyContinue'
[Console]::InputEncoding = [Text.Encoding]::UTF8; [Console]::OutputEncoding = [Text.Encoding]::UTF8
$e = [Console]::In.ReadToEnd() | ConvertFrom-Json
$rl = $e.rate_limits
$u = [ordered]@{ sid = [string]$e.session_id; t = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
  five = $rl.five_hour.used_percentage; fiveAt = $rl.five_hour.resets_at
  week = $rl.seven_day.used_percentage; weekAt = $rl.seven_day.resets_at
  ctx = $e.context_window.used_percentage }
if ($env:DEGEN_LEAD -match '^\d+$' -and $u.sid -match '^[\w\-]+$') {
  $D = Join-Path $env:USERPROFILE 'RobloxGames\.degen\usage'; New-Item -ItemType Directory -Force -Path $D | Out-Null
  [IO.File]::WriteAllText((Join-Path $D "$($env:DEGEN_LEAD).json"), ($u | ConvertTo-Json -Compress), (New-Object Text.UTF8Encoding $false))
}
function P($v) { if ($null -ne $v -and "$v" -ne '') { '{0:0}%' -f [double]$v } else { '-' } }
$out = "Usage: 5h $(P $u.five) | week $(P $u.week) | context $(P $u.ctx)"
if ($u.fiveAt) { $out += ' | 5h resets ' + [DateTimeOffset]::FromUnixTimeSeconds([long]$u.fiveAt).LocalDateTime.ToString('HH:mm') }
$out += ' | pauses at 95%'
$out
