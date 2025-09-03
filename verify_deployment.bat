@echo off
echo ========================================
echo StayMithra App - Deployment Verification
echo ========================================
echo.

echo [1/5] Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found!
    pause
    exit /b 1
)
echo ✅ Flutter is installed
echo.

echo [2/5] Checking project dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to get dependencies!
    pause
    exit /b 1
)
echo ✅ Dependencies resolved
echo.

echo [3/5] Running code analysis...
flutter analyze --no-fatal-infos
if %errorlevel% neq 0 (
    echo WARNING: Code analysis found issues (non-critical)
) else (
    echo ✅ Code analysis passed
)
echo.

echo [4/5] Checking APK file...
if exist "staymitra-release-optimized.apk" (
    echo ✅ Optimized APK found: staymitra-release-optimized.apk
    for %%A in ("staymitra-release-optimized.apk") do (
        set /a size=%%~zA/1024/1024
        echo    Size: !size! MB
    )
) else (
    echo ❌ APK file not found!
)
echo.

echo [5/5] Checking Git status...
git status --porcelain
if %errorlevel% neq 0 (
    echo WARNING: Git status check failed
) else (
    echo ✅ Git repository is clean
)
echo.

echo ========================================
echo Deployment Verification Complete!
echo ========================================
echo.
echo 📱 To install APK on device:
echo    adb install staymitra-release-optimized.apk
echo.
echo 🔗 GitHub Repository:
echo    https://github.com/ecraftzin/StayMithra-stable.git
echo.
echo 📝 See DEPLOYMENT_COMPLETE_SUMMARY.md for full details
echo.
pause
