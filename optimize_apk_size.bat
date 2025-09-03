@echo off
echo ========================================
echo StayMithra APK Size Optimization Script
echo Target: Reduce from 60.1MB to 20-25MB
echo ========================================

echo.
echo Step 1: Cleaning previous builds...
call flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed
    pause
    exit /b 1
)

echo.
echo Step 2: Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed
    pause
    exit /b 1
)

echo.
echo Step 3: Analyzing current APK composition...
call flutter build apk --release --analyze-size
if %errorlevel% neq 0 (
    echo ERROR: APK build with analysis failed
    pause
    exit /b 1
)

echo.
echo Step 4: Building optimized release APK with all optimizations...
call flutter build apk --release --shrink --obfuscate --split-debug-info=build/debug-info --dart-define=flutter.inspector.structuredErrors=false
if %errorlevel% neq 0 (
    echo ERROR: Optimized APK build failed
    pause
    exit /b 1
)

echo.
echo Step 5: Building App Bundle (AAB) for Play Store...
call flutter build appbundle --release --shrink --obfuscate --split-debug-info=build/debug-info --dart-define=flutter.inspector.structuredErrors=false
if %errorlevel% neq 0 (
    echo ERROR: App Bundle build failed
    pause
    exit /b 1
)

echo.
echo Step 6: Checking file sizes...
echo.
echo APK Files:
for %%f in (build\app\outputs\flutter-apk\*.apk) do (
    echo %%f - %%~zf bytes
)
echo.
echo App Bundle:
for %%f in (build\app\outputs\bundle\release\*.aab) do (
    echo %%f - %%~zf bytes
)

echo.
echo ========================================
echo Build completed successfully!
echo ========================================
echo.
echo APK Location: build\app\outputs\flutter-apk\
echo AAB Location: build\app\outputs\bundle\release\
echo.
echo RECOMMENDATION: Use AAB for Play Store (smaller download size)
echo For direct installation, use the APK files generated per architecture
echo.
pause
