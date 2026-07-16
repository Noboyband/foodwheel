# รวม src/template.html + src/loop.mp3 -> index.html
# เพลงถูกฝังเป็น base64 เพราะหน้านี้ต้องเป็นไฟล์เดียวจบ ไม่มี dependency ภายนอก
#
# หมายเหตุ: ไฟล์นี้ต้องบันทึกเป็น UTF-8 with BOM เท่านั้น
# เพราะ Windows PowerShell 5.1 จะอ่านเป็น ANSI ถ้าไม่มี BOM แล้วภาษาไทยจะพังทั้งไฟล์

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

$tpl = Join-Path $root "src\template.html"
$mp3 = Join-Path $root "src\loop.mp3"
$out = Join-Path $root "index.html"

foreach ($f in @($tpl, $mp3)) {
  if (-not (Test-Path $f)) { throw "ไม่พบไฟล์: $f" }
}

$html = [System.IO.File]::ReadAllText($tpl, [System.Text.Encoding]::UTF8)
if ($html -notmatch '__BGM_B64__') {
  throw "ไม่พบ placeholder __BGM_B64__ ใน template.html"
}

$b64 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($mp3))
$html = $html.Replace('__BGM_B64__', $b64)

# ต้องเป็น UTF-8 ไม่มี BOM ไม่งั้นภาษาไทยในหน้าเว็บเพี้ยน
[System.IO.File]::WriteAllText($out, $html, (New-Object System.Text.UTF8Encoding($false)))

$kb = [math]::Round((Get-Item $out).Length / 1KB, 0)
Write-Host "build เสร็จ -> index.html ($kb KB)" -ForegroundColor Green