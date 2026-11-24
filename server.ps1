$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add('http://localhost:8080/')
$listener.Start()
Write-Host 'Server running at http://localhost:8080'

while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $path = $ctx.Request.Url.LocalPath.TrimStart('/')
    if ($path -eq '') { $path = 'index.html' }
    $file = "C:\Users\Eunha\OneDrive\Desktop\dp_12주차 실습\$path"
    $resp = $ctx.Response

    if (Test-Path $file) {
        $ext = [System.IO.Path]::GetExtension($file)
        $mime = switch ($ext) {
            '.html' { 'text/html; charset=utf-8' }
            '.js'   { 'application/javascript' }
            '.glb'  { 'model/gltf-binary' }
            '.css'  { 'text/css' }
            default { 'application/octet-stream' }
        }
        $resp.ContentType = $mime
        $resp.Headers.Add('Access-Control-Allow-Origin', '*')
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $resp.ContentLength64 = $bytes.Length
        $resp.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $resp.StatusCode = 404
    }
    $resp.Close()
}
