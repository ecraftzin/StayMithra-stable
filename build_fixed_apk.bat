@echo off
echo ========================================
echo StayMithra APK Build - ISSUE FIXED
echo ========================================
echo.
echo Fixed: Removed unsupported useProguard() method
echo R8 optimization is now enabled by default
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
echo Step 3: Building optimized APK with all size reductions...
call flutter build apk --release --shrink --obfuscate --split-debug-info=build/debug-info
if %errorlevel% neq 0 (
    echo ERROR: APK build failed
    pause
    exit /b 1
)

echo.
echo Step 4: Building App Bundle for Play Store...
call flutter build appbundle --release --shrink --obfuscate --split-debug-info=build/debug-info
if %errorlevel% neq 0 (
    echo ERROR: App Bundle build failed
    pause
    exit /b 1
)

echo.
echo Step 5: Checking file sizes...
echo.
echo APK Files Generated:
for %%f in (build\app\outputs\flutter-apk\*.apk) do (
    set /a size=%%~zf/1048576
    echo %%~nxf - !size! MB
)

echo.
echo App Bundle Generated:
for %%f in (build\app\outputs\bundle\release\*.aab) do (
    set /a size=%%~zf/1048576
    echo %%~nxf - !size! MB
)

echo.
echo ========================================
echo BUILD SUCCESSFUL!
echo ========================================
echo.
echo Expected APK sizes: 15-25 MB each
echo Expected AAB size: 12-20 MB
echo.
echo Files location:
echo APKs: build\app\outputs\flutter-apk\
echo AAB:  build\app\outputs\bundle\release\
echo.
echo RECOMMENDATION: Use AAB file for Play Store submission
echo.
pause
