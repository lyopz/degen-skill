# Prints what the ChatGPT window looks like to the picture script (for fixing gpt-image.ps1).
$port = 9333
$t = @(Invoke-RestMethod "http://127.0.0.1:$port/json" -TimeoutSec 3) | Where-Object { $_.type -eq 'page' } | Select-Object -First 1
if (-not $t) { 'NO_CHATGPT_WINDOW (run gpt-image.ps1 first)'; exit }
"page: " + $t.url
$ws = New-Object Net.WebSockets.ClientWebSocket; $ws.ConnectAsync([Uri]$t.webSocketDebuggerUrl, [Threading.CancellationToken]::None).Wait(8000) | Out-Null
$js = @'
(()=>{const out={busy:!!document.querySelector('[data-testid=stop-button],button[aria-label*=Stop]'),
imgs:[...document.images].map(i=>({w:i.naturalWidth,h:i.naturalHeight,src:(i.currentSrc||i.src).slice(0,90),alt:(i.alt||'').slice(0,30)})).filter(x=>x.w>100),
canvases:document.querySelectorAll('canvas').length,
bg:[...document.querySelectorAll('[style*="background-image"]')].slice(0,5).map(e=>e.style.backgroundImage.slice(0,90))};return JSON.stringify(out,null,1)})()
'@
$msg = @{ id = 1; method = 'Runtime.evaluate'; params = @{ expression = $js; returnByValue = $true } } | ConvertTo-Json -Depth 5 -Compress
$b = [Text.Encoding]::UTF8.GetBytes($msg); $ws.SendAsync([ArraySegment[byte]]::new($b), 'Text', $true, [Threading.CancellationToken]::None).Wait() | Out-Null
$buf = New-Object byte[] 4194304; $ms = New-Object IO.MemoryStream
do { $r = $ws.ReceiveAsync([ArraySegment[byte]]::new($buf), [Threading.CancellationToken]::None); $r.Wait() | Out-Null; $ms.Write($buf, 0, $r.Result.Count) } while (-not $r.Result.EndOfMessage)
$res = [Text.Encoding]::UTF8.GetString($ms.ToArray()) | ConvertFrom-Json
if ($res.result.exceptionDetails) { 'JS error: ' + $res.result.exceptionDetails.text } else { $res.result.result.value }
