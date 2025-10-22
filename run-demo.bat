@echo off
REM Demo starter for DX PDF-Viewer
REM Starts the application with readme.pdf

echo Starting DX PDF-Viewer with demo PDF...

if not exist "Win32\Debug\DxPdfViewer.exe" (
    echo ERROR: DxPdfViewer.exe not found!
    echo Please compile the project first.
    pause
    exit /b 1
)

if not exist "readme.pdf" (
    echo ERROR: readme.pdf not found!
    echo Please create the PDF first using Typora or another Markdown to PDF converter.
    pause
    exit /b 1
)

Win32\Debug\DxPdfViewer.exe "%~dp0readme.pdf"

