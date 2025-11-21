# Upload release assets to GitHub
param(
    [string]$ReleaseId = "264196042",
    [string]$Owner = "omonien",
    [string]$Repo = "DX.Pdfium4D"
)

# Get GitHub token from environment or prompt
$token = $env:GITHUB_TOKEN
if (-not $token) {
    Write-Host "Error: GITHUB_TOKEN environment variable not set" -ForegroundColor Red
    Write-Host "Please set it with: `$env:GITHUB_TOKEN = 'your_token_here'" -ForegroundColor Yellow
    exit 1
}

$headers = @{
    'Authorization' = "token $token"
    'Accept' = 'application/vnd.github.v3+json'
}

# Files to upload
$files = @(
    "release\DX.PdfViewer-v1.0.0-Win32.zip",
    "release\DX.PdfViewer-v1.0.0-Win64.zip"
)

foreach ($file in $files) {
    if (-not (Test-Path $file)) {
        Write-Host "Error: File not found: $file" -ForegroundColor Red
        continue
    }
    
    $fileName = Split-Path $file -Leaf
    $uploadUrl = "https://uploads.github.com/repos/$Owner/$Repo/releases/$ReleaseId/assets?name=$fileName"
    
    Write-Host "Uploading $fileName..." -ForegroundColor Cyan
    
    try {
        $fileBytes = [System.IO.File]::ReadAllBytes((Resolve-Path $file))
        $uploadHeaders = $headers.Clone()
        $uploadHeaders['Content-Type'] = 'application/zip'
        
        $response = Invoke-RestMethod -Uri $uploadUrl -Method Post -Headers $uploadHeaders -Body $fileBytes
        Write-Host "✓ Successfully uploaded $fileName" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Failed to upload $fileName" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

Write-Host "`nDone!" -ForegroundColor Green

