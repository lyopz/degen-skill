# One-time setup: tell the Lead window where your Customuse MCP is.
# Usage (normal PowerShell):  powershell -NoProfile -File "$HOME\.claude\degen-skill\assets\roblox-app\customuse-setup.ps1" -Url "<Customuse MCP address>"
# Saved outside the repo (~/RobloxGames/.degen/customuse-mcp.txt), so git pull never overwrites it. Run with -Url "" to remove.
param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Url)
$D = Join-Path $env:USERPROFILE 'RobloxGames\.degen'; New-Item -ItemType Directory -Force -Path $D | Out-Null
$f = Join-Path $D 'customuse-mcp.txt'
if (-not $Url.Trim()) { Remove-Item $f -Force -ErrorAction SilentlyContinue; 'Customuse MCP removed.'; exit 0 }
if ($Url.Trim() -notmatch '^https://') { 'That does not look like an MCP address (should start with https://).'; exit 1 }
[IO.File]::WriteAllText($f, $Url.Trim(), (New-Object Text.UTF8Encoding $false))
'Saved. Next Lead window loads Customuse. First time: type /mcp -> customuse -> Authenticate.'
