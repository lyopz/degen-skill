# Uploads local files to lyopz's Roblox account (Open Cloud Assets API) so the Lead can insert them in Studio by asset id.
# No clicks for lyopz. One-time setup: roblox-cloud-setup.ps1.
# Usage (from the Lead):
#   powershell -ExecutionPolicy Bypass -NoProfile -File "$env:DEGEN_APP\roblox-upload.ps1" -Project <project> -Path "<file>|<file 2>" [-Name <name>]
# Types (picked from the extension):
#   .glb .gltf .fbx .rbxm .rbxmx -> Model (MeshParts with real MeshIds, glTF textures included)
#   .obj -> converted to .glb with Blender (if installed), then Model
#   .png .jpg .jpeg .bmp .tga   -> Decal (image id for SurfaceAppearance / Decal / ImageLabel)
#   .mp3 .ogg .wav .flac        -> Audio (max 7 min; 10 a month if not ID-verified)
#   .mp4 .mov                   -> Video
# Prints one JSON line per file: {"file","type","assetId","state"}  state = APPROVED | REVIEWING | REJECTED | CACHED
# or a line starting with ERROR. NO_KEY = setup not done. Same file again = cached id (per project, roblox-assets.json); -Force uploads again.
param([Parameter(Mandatory = $true)][string]$Path, [string]$Project = '', [string]$Name = '', [string]$Description = 'Uploaded by Degen Roblox', [switch]$Force, [int]$WaitSeconds = 180)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Net.Http
$RG = Join-Path $env:USERPROFILE 'RobloxGames'
$cfgFile = Join-Path $RG '.degen\roblox-cloud.json'
if (-not (Test-Path $cfgFile)) { 'NO_KEY - run once: powershell -ExecutionPolicy Bypass -NoProfile -File "$HOME\.claude\degen-skill\assets\roblox-app\roblox-cloud-setup.ps1"'; exit 2 }
$cfg = Get-Content $cfgFile -Raw | ConvertFrom-Json
try {
  $sec = ConvertTo-SecureString $cfg.key
  $key = [Runtime.InteropServices.Marshal]::PtrToStringBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
} catch { 'NO_KEY - saved key could not be read (other Windows user?). Run roblox-cloud-setup.ps1 again.'; exit 2 }
$creator = if ($cfg.groupId) { @{ groupId = [string]$cfg.groupId } } else { @{ userId = [string]$cfg.userId } }

$types = @{
  '.glb' = @('Model', 'model/gltf-binary'); '.gltf' = @('Model', 'model/gltf+json'); '.fbx' = @('Model', 'model/fbx')
  '.rbxm' = @('Model', 'model/x-rbxm'); '.rbxmx' = @('Model', 'model/x-rbxm')
  '.png' = @('Decal', 'image/png'); '.jpg' = @('Decal', 'image/jpeg'); '.jpeg' = @('Decal', 'image/jpeg'); '.bmp' = @('Decal', 'image/bmp'); '.tga' = @('Decal', 'image/tga')
  '.mp3' = @('Audio', 'audio/mpeg'); '.ogg' = @('Audio', 'audio/ogg'); '.wav' = @('Audio', 'audio/wav'); '.flac' = @('Audio', 'audio/flac')
  '.mp4' = @('Video', 'video/mp4'); '.mov' = @('Video', 'video/mov')
}

$cacheFile = if ($Project) { Join-Path $RG "$Project\roblox-assets.json" } else { Join-Path $RG '.degen\roblox-assets.json' }
$cache = @{}
if (Test-Path $cacheFile) { (Get-Content $cacheFile -Raw | ConvertFrom-Json).PSObject.Properties | ForEach-Object { $cache[$_.Name] = $_.Value } }
function SaveCache { New-Item -ItemType Directory -Force -Path (Split-Path $cacheFile) | Out-Null
  [IO.File]::WriteAllText($cacheFile, ($cache | ConvertTo-Json -Depth 4), (New-Object Text.UTF8Encoding $false)) }
function Out-Line($o) { $o | ConvertTo-Json -Compress }

function Convert-Obj([string]$obj) {
  $bl = Get-ChildItem "$env:ProgramFiles\Blender Foundation" -Recurse -Filter blender.exe -ErrorAction SilentlyContinue | Sort-Object FullName -Descending | Select-Object -First 1
  if (-not $bl) { return $null }
  $glb = [IO.Path]::ChangeExtension($obj, '.glb')
  $py = "import bpy;bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete();" +
        "bpy.ops.wm.obj_import(filepath=r'''$obj''');bpy.ops.export_scene.gltf(filepath=r'''$glb''',export_format='GLB')"
  & $bl.FullName --factory-startup -b --python-expr $py 2>&1 | Out-Null
  if (Test-Path $glb) { return $glb } else { return $null }
}

$http = New-Object System.Net.Http.HttpClient
$http.Timeout = [TimeSpan]::FromMinutes(5)
$http.DefaultRequestHeaders.Add('x-api-key', $key)

foreach ($p in ($Path -split '\|' | ForEach-Object { $_.Trim().Trim('"') } | Where-Object { $_ })) {
  try {
    if (-not (Test-Path $p)) { "ERROR not found: $p"; continue }
    $file = (Resolve-Path $p).Path
    $ext = [IO.Path]::GetExtension($file).ToLower()
    if ($ext -eq '.obj') {
      $glb = Convert-Obj $file
      if (-not $glb) { "ERROR .obj needs converting and Blender wasn't found: export it as .glb (Unity DegenPolish.ExportForRoblox or Customuse) - $file"; continue }
      $file = $glb; $ext = '.glb'
    }
    if (-not $types.ContainsKey($ext)) { "ERROR unsupported file type ${ext}: $file"; continue }
    $assetType = $types[$ext][0]; $mime = $types[$ext][1]
    $len = (Get-Item $file).Length
    if ($len -gt 20MB -and $assetType -ne 'Video') { "ERROR over Roblox's 20 MB limit ($([math]::Round($len/1MB,1)) MB) - decimate or shrink textures: $file"; continue }
    $hash = (Get-FileHash $file -Algorithm SHA256).Hash
    if (-not $Force -and $cache.ContainsKey($hash)) {
      $c = $cache[$hash]; Out-Line ([ordered]@{ file = $file; type = $c.type; assetId = $c.assetId; state = 'CACHED' }); continue
    }
    $display = if ($Name) { $Name } else { [IO.Path]::GetFileNameWithoutExtension($file) }
    $display = ($display -replace '[^\w\- ]', ' ').Trim(); if ($display.Length -gt 50) { $display = $display.Substring(0, 50) }
    $req = [ordered]@{ assetType = $assetType; displayName = $display; description = $Description; creationContext = @{ creator = $creator } }

    $form = New-Object System.Net.Http.MultipartFormDataContent
    $form.Add([System.Net.Http.StringContent]::new(($req | ConvertTo-Json -Depth 5 -Compress), [Text.Encoding]::UTF8, 'application/json'), '"request"')
    $bytes = [System.Net.Http.ByteArrayContent]::new([IO.File]::ReadAllBytes($file))
    $bytes.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse($mime)
    $form.Add($bytes, '"fileContent"', ('"' + [IO.Path]::GetFileName($file) + '"'))   # quoted names work in both PS 5.1 (.NET Framework) and PS 7
    $res = $http.PostAsync('https://apis.roblox.com/assets/v1/assets', $form).Result
    $body = $res.Content.ReadAsStringAsync().Result
    if (-not $res.IsSuccessStatusCode) { "ERROR upload $([int]$res.StatusCode): $body ($file)"; continue }
    $op = ($body | ConvertFrom-Json).path   # operations/<id>

    $done = $null; $until = (Get-Date).AddSeconds($WaitSeconds)
    while ((Get-Date) -lt $until) {
      $r = $http.GetAsync("https://apis.roblox.com/assets/v1/$op").Result
      $j = $r.Content.ReadAsStringAsync().Result | ConvertFrom-Json
      if ($j.done) { $done = $j; break }
      Start-Sleep -Seconds 2
    }
    if (-not $done) { "ERROR still processing after $WaitSeconds s ($op): $file"; continue }
    if ($done.error) { "ERROR Roblox: $($done.error.message) ($file)"; continue }
    $id = [string]$done.response.assetId
    $state = ([string]$done.response.moderationResult.moderationState) -replace '^MODERATION_STATE_', ''
    if (-not $state) { $state = 'REVIEWING' }
    $cache[$hash] = [ordered]@{ type = $assetType; assetId = $id; name = $display; file = $file; at = (Get-Date -Format 'yyyy-MM-dd HH:mm') }
    SaveCache
    Out-Line ([ordered]@{ file = $file; type = $assetType; assetId = $id; state = $state })
  } catch { "ERROR $($_.Exception.Message) ($p)" }
}
