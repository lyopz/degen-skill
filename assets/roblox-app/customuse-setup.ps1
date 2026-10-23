# One-time setup: tell the Lead window where your Customuse MCP is and your Customuse API key (starts with cmk).
# Usage (normal PowerShell):
#   powershell -NoProfile -File "$HOME\.claude\degen-skill\assets\roblox-app\customuse-setup.ps1" -Url "<Customuse MCP address>" -Key "<cmk... key>"
# Saved only on this PC (~/RobloxGames/.degen/customuse-mcp.json), never in the repo. Run with -Url "" to remove.
# If Customuse says the key goes in a different header (e.g. x-api-key), add -Header "x-api-key" (default: Authorization: Bearer <key>).
param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Url, [string]$Key = '', [string]$Header = 'Authorization')
$D = Join-Path $env:USERPROFILE 'RobloxGames\.degen'; New-Item -ItemType Directory -Force -Path $D | Out-Null
$f = Join-Path $D 'customuse-mcp.json'
Remove-Item (Join-Path $D 'customuse-mcp.txt') -Force -ErrorAction SilentlyContinue
if (-not $Url.Trim()) { Remove-Item $f -Force -ErrorAction SilentlyContinue; 'Customuse MCP removed.'; exit 0 }
if ($Url.Trim() -notmatch '^https://') { 'That does not look like an MCP address (should start with https://).'; exit 1 }
$srv = [ordered]@{ type = 'http'; url = $Url.Trim() }
if ($Key.Trim()) {
  $v = if ($Header -eq 'Authorization') { 'Bearer ' + $Key.Trim() } else { $Key.Trim() }
  $srv.headers = [ordered]@{ $Header = $v }
}
[IO.File]::WriteAllText($f, ($srv | ConvertTo-Json -Depth 4), (New-Object Text.UTF8Encoding $false))
if ($Key.Trim()) { 'Saved (with key). Next Lead window loads Customuse.' } else { 'Saved. Next Lead window loads Customuse. First time: type /mcp -> customuse -> Authenticate.' }
