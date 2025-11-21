@echo off
REM Post-build script to copy PDFium DLL to DX PDF Viewer output directory
REM Usage: copy-pdfium-dll.bat <Platform> <Config>
REM Example: copy-pdfium-dll.bat Win32 Debug

set PLATFORM=%1
set CONFIG=%2

if "%PLATFORM%"=="" set PLATFORM=Win32
if "%CONFIG%"=="" set CONFIG=Debug

REM Set paths relative to repository root
set OUTPUT_DIR=src\PdfViewer\%PLATFORM%\%CONFIG%
set SOURCE_DLL=lib\pdfium-bin\bin\pdfium.dll

echo.
echo ========================================
echo Copying PDFium DLL to DX PDF Viewer
echo ========================================
echo Platform: %PLATFORM%
echo Config:   %CONFIG%
echo Target:   %OUTPUT_DIR%
echo.

if not exist "%OUTPUT_DIR%" (
  echo Creating output directory: %OUTPUT_DIR%
  mkdir "%OUTPUT_DIR%"
)

if exist "%SOURCE_DLL%" (
  copy /Y "%SOURCE_DLL%" "%OUTPUT_DIR%\pdfium.dll"
  if errorlevel 1 (
    echo ERROR: Failed to copy PDFium DLL
    exit /b 1
  )
  echo.
  echo ========================================
  echo PDFium DLL copied successfully!
  echo ========================================
) else (
  echo ERROR: Source DLL not found: %SOURCE_DLL%
  echo Please ensure the PDFium binaries are in lib\pdfium-bin\bin\
  exit /b 1
)

