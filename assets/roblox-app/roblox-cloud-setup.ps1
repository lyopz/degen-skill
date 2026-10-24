# One-time setup: lets the Lead upload 3D models, pictures and sounds to Roblox by itself (Open Cloud Assets API).
# 1) https://create.roblox.com/dashboard/credentials -> API Keys -> Create API Key
#    Access Permissions: add "Assets" -> tick Read + Write.  Security: Accepted IP Addresses 0.0.0.0/0.  Create, copy the key.
# 2) Normal PowerShell:
#    powershell -ExecutionPolicy Bypass -NoProfile -File "$HOME\.claude\degen-skill\assets\roblox-app\roblox-cloud-setup.ps1"
#    It asks for the key (hidden) and your Roblox user id (the number in your profile link). Add -GroupId <id> if your games are owned by a group.
# The key is saved only on this PC, encrypted for your Windows user (~/RobloxGames/.degen/roblox-cloud.json). Never in the repo.
# -Remove deletes it.
param([string]$Key = '', [string]$UserId = '', [string]$GroupId = '', [switch]$Remove)
$D = Join-Path $env:USERPROFILE 'RobloxGames\.degen'; New-Item -ItemType Directory -Force -Path $D | Out-Null
$f = Join-Path $D 'roblox-cloud.json'
if ($Remove) { Remove-Item $f -Force -ErrorAction SilentlyContinue; 'Roblox upload key removed.'; exit 0 }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not $Key.Trim()) {
  $sec = Read-Host 'Paste your Roblox Open Cloud API key (hidden)' -AsSecureString
  $Key = [Runtime.InteropServices.Marshal]::PtrToStringBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
}
$Key = $Key.Trim()
if (-not $Key) { 'No key given. Nothing saved.'; exit 1 }

# Try to read the owner from the key itself (best effort; falls back to asking).
if (-not $UserId -and -not $GroupId) {
  try {
    $info = Invoke-RestMethod -Method Post -Uri 'https://apis.roblox.com/api-keys/v1/introspect' -ContentType 'application/json' -Body (@{ apiKey = $Key } | ConvertTo-Json)
    if ($info.authorizedUserId) { $UserId = [string]$info.authorizedUserId; "Key belongs to user $UserId." }
  } catch {}
}
if (-not $UserId -and -not $GroupId) { $UserId = (Read-Host 'Your Roblox user id (number in your profile link roblox.com/users/<id>/profile)').Trim() }
if ($UserId -and $UserId -notmatch '^\d+$') { 'User id must be a number.'; exit 1 }
if ($GroupId -and $GroupId -notmatch '^\d+$') { 'Group id must be a number.'; exit 1 }

# Check the key works: a made-up operation id gives 404/400 with a good key, 401/403 with a bad one.
$ok = $true
try { Invoke-RestMethod -Uri 'https://apis.roblox.com/assets/v1/operations/00000000-0000-0000-0000-000000000000' -Headers @{ 'x-api-key' = $Key } | Out-Null }
catch {
  $code = 0; if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
  if ($code -eq 401 -or $code -eq 403) { $ok = $false }
}
if (-not $ok) { 'Roblox refused the key (401/403). Check it has Assets Read + Write and IP 0.0.0.0/0, then run this again.'; exit 1 }

$enc = ConvertTo-SecureString $Key -AsPlainText -Force | ConvertFrom-SecureString   # Windows DPAPI: only this user on this PC can read it
$cfg = [ordered]@{ key = $enc; userId = $UserId; groupId = $GroupId; saved = (Get-Date -Format 'yyyy-MM-dd') }
[IO.File]::WriteAllText($f, ($cfg | ConvertTo-Json), (New-Object Text.UTF8Encoding $false))
$who = if ($GroupId) { "group $GroupId" } else { "user $UserId" }
"Saved. The Lead can now upload models, pictures and sounds to Roblox as $who."
