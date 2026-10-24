# store-search.ps1 — search free Creator Store models with ratings (public toolbox web API, no login)
# use: powershell -NoProfile -File store-search.ps1 -Query "egg hatch system" [-Count 20] [-Category Model|Audio|Decal|Plugin|MeshPart]
param(
  [Parameter(Mandatory = $true)][string]$Query,
  [int]$Count = 20,
  [string]$Category = 'Model'
)
$ErrorActionPreference = 'Stop'
$cat = @{ Model = 10; Decal = 13; Audio = 3; MeshPart = 40; Plugin = 8 }[$Category]
if (-not $cat) { $cat = 10 }
$q = [uri]::EscapeDataString($Query)
try {
  $list = Invoke-RestMethod "https://apis.roblox.com/toolbox-service/v1/marketplace/$cat`?keyword=$q&num=$Count&includeOnlyVerifiedCreators=false"
} catch {
  Write-Host "Search failed: $($_.Exception.Message). Use search.luau in Studio instead."; exit 1
}
$ids = @($list.data | ForEach-Object { $_.id })
if ($ids.Count -eq 0) { Write-Host "No results for '$Query'."; exit 0 }
$details = Invoke-RestMethod "https://apis.roblox.com/toolbox-service/v1/items/details?assetIds=$($ids -join ',')"
$rows = foreach ($d in $details.data) {
  $up = [int]$d.voting.upVotes; $down = [int]$d.voting.downVotes; $votes = $up + $down
  $pct = if ($votes -gt 0) { [math]::Round(100 * $up / $votes) } else { 0 }
  $verified = [bool]$d.creator.verified -or [bool]$d.creator.isVerifiedCreator
  $free = -not $d.product -or -not $d.product.price -or [double]$d.product.price -eq 0
  # score: rating weighted by vote count, bonus for verified creators
  $score = [math]::Round($pct * [math]::Min(1, $votes / 50) + ($(if ($verified) { 15 } else { 0 })))
  [pscustomobject]@{
    Id = $d.asset.id; Name = $d.asset.name; Creator = $d.creator.name; Verified = $verified
    Up = $up; Down = $down; Pct = $pct; Free = $free; Score = $score
  }
}
$rows | Where-Object Free | Sort-Object Score -Descending | Format-Table Id, Score, Pct, Up, Down, Verified, Creator, Name -AutoSize
