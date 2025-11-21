@echo off
setlocal

echo ========================================
echo Building DX PDF Viewer Release Versions
echo ========================================
echo.

REM Set Delphi environment
call "C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat"

REM Clean previous builds
echo Cleaning previous builds...
if exist "src\PdfViewer\Win32\Release" rmdir /s /q "src\PdfViewer\Win32\Release"
if exist "src\PdfViewer\Win64\Release" rmdir /s /q "src\PdfViewer\Win64\Release"
if exist "release" rmdir /s /q "release"

echo.
echo ========================================
echo Building Win32 Release...
echo ========================================
msbuild src\PdfViewer\DX.PdfViewer.dproj /t:Build /p:Config=Release /p:Platform=Win32 /v:minimal
if errorlevel 1 (
    echo ERROR: Win32 build failed!
    exit /b 1
)

echo.
echo ========================================
echo Building Win64 Release...
echo ========================================
msbuild src\PdfViewer\DX.PdfViewer.dproj /t:Build /p:Config=Release /p:Platform=Win64 /v:minimal
if errorlevel 1 (
    echo ERROR: Win64 build failed!
    exit /b 1
)

echo.
echo ========================================
echo Creating release packages...
echo ========================================

REM Create release directories
mkdir release\DX.PdfViewer-Win32
mkdir release\DX.PdfViewer-Win64

REM Copy Win32 files
echo Copying Win32 files...
copy "src\PdfViewer\Win32\Release\DX.PdfViewer.exe" "release\DX.PdfViewer-Win32\"
copy "lib\pdfium-bin\bin\pdfium.dll" "release\DX.PdfViewer-Win32\"
copy "samples\*.pdf" "release\DX.PdfViewer-Win32\"
copy "README.md" "release\DX.PdfViewer-Win32\"
copy "LICENSE" "release\DX.PdfViewer-Win32\"

REM Copy Win64 files
echo Copying Win64 files...
copy "src\PdfViewer\Win64\Release\DX.PdfViewer.exe" "release\DX.PdfViewer-Win64\"
copy "lib\pdfium-bin\bin\pdfium.dll" "release\DX.PdfViewer-Win64\"
copy "samples\*.pdf" "release\DX.PdfViewer-Win64\"
copy "README.md" "release\DX.PdfViewer-Win64\"
copy "LICENSE" "release\DX.PdfViewer-Win64\"

echo.
echo ========================================
echo Creating ZIP archives...
echo ========================================

REM Create ZIP files using PowerShell
powershell -Command "Compress-Archive -Path 'release\DX.PdfViewer-Win32\*' -DestinationPath 'release\DX.PdfViewer-v1.0.0-Win32.zip' -Force"
powershell -Command "Compress-Archive -Path 'release\DX.PdfViewer-Win64\*' -DestinationPath 'release\DX.PdfViewer-v1.0.0-Win64.zip' -Force"

echo.
echo ========================================
echo Build Complete!
echo ========================================
echo.
echo Release packages created:
echo - release\DX.PdfViewer-v1.0.0-Win32.zip
echo - release\DX.PdfViewer-v1.0.0-Win64.zip
echo.

endlocal

