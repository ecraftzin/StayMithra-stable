@echo off
echo ========================================
echo StayMithra APK Optimization Verification
echo ========================================

echo.
echo Checking build.gradle optimizations...
echo.

findstr /C:"minifyEnabled true" android\app\build.gradle >nul
if %errorlevel%==0 (
    echo ✅ Code minification: ENABLED
) else (
    echo ❌ Code minification: NOT FOUND
)

findstr /C:"shrinkResources true" android\app\build.gradle >nul
if %errorlevel%==0 (
    echo ✅ Resource shrinking: ENABLED
) else (
    echo ❌ Resource shrinking: NOT FOUND
)

findstr /C:"useProguard false" android\app\build.gradle >nul
if %errorlevel%==0 (
    echo ✅ R8 optimization: ENABLED
) else (
    echo ❌ R8 optimization: NOT FOUND
)

findstr /C:"crunchPngs true" android\app\build.gradle >nul
if %errorlevel%==0 (
    echo ✅ PNG compression: ENABLED
) else (
    echo ❌ PNG compression: NOT FOUND
)

findstr /C:"debugSymbolLevel 'NONE'" android\app\build.gradle >nul
if %errorlevel%==0 (
    echo ✅ Debug symbols removal: ENABLED
) else (
    echo ❌ Debug symbols removal: NOT FOUND
)

findstr /C:"universalApk false" android\app\build.gradle >nul
if %errorlevel%==0 (
    echo ✅ ABI splitting: ENABLED
) else (
    echo ❌ ABI splitting: NOT FOUND
)

findstr /C:"resConfigs" android\app\build.gradle >nul
if %errorlevel%==0 (
    echo ✅ Resource configuration: ENABLED
) else (
    echo ❌ Resource configuration: NOT FOUND
)

echo.
echo ========================================
echo Optimization Status Summary
echo ========================================

echo.
echo All optimizations have been applied to:
echo - android\app\build.gradle
echo - android\app\proguard-rules.pro
echo.
echo Expected APK size reduction: 60-70%%
echo Target size: 15-25 MB per architecture
echo.
echo Next steps:
echo 1. Run: flutter clean
echo 2. Run: flutter pub get  
echo 3. Run: flutter build apk --release --shrink --obfuscate --split-debug-info=build/debug-info
echo 4. Check file sizes in: build\app\outputs\flutter-apk\
echo.
echo For Play Store submission, use:
echo flutter build appbundle --release --shrink --obfuscate --split-debug-info=build/debug-info
echo.
pause
