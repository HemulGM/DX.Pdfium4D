# Demo starter for DX PDF-Viewer
# Starts the application with readme.pdf

Write-Host "Starting DX PDF-Viewer with demo PDF..." -ForegroundColor Green

$exePath = Join-Path $PSScriptRoot "Win32\Debug\DxPdfViewer.exe"
$pdfPath = Join-Path $PSScriptRoot "readme.pdf"

# Resolve to absolute paths
$exePath = Resolve-Path $exePath -ErrorAction SilentlyContinue
$pdfPath = Resolve-Path $pdfPath -ErrorAction SilentlyContinue

if (-not $exePath -or -not (Test-Path $exePath)) {
    Write-Host "ERROR: DxPdfViewer.exe not found!" -ForegroundColor Red
    Write-Host "Please compile the project first." -ForegroundColor Yellow
    exit 1
}

if (-not $pdfPath -or -not (Test-Path $pdfPath)) {
    Write-Host "ERROR: readme.pdf not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please create the PDF first:" -ForegroundColor Yellow
    Write-Host "  1. Open README.md in Typora" -ForegroundColor White
    Write-Host "  2. Export as PDF (File -> Export -> PDF)" -ForegroundColor White
    Write-Host "  3. Save as readme.pdf in the project root" -ForegroundColor White
    Write-Host ""
    exit 1
}

Start-Process -FilePath $exePath -ArgumentList "`"$pdfPath`""
Write-Host "Application started." -ForegroundColor Green

