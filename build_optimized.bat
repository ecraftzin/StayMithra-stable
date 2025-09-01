@echo off
echo 🚀 Building Optimized StayMithra APK...
echo.

echo 📦 Cleaning previous builds...
flutter clean
echo.

echo 📥 Getting dependencies...
flutter pub get
echo.

echo 🔧 Building optimized release APK...
flutter build apk --release --shrink --obfuscate --split-debug-info=build/debug-info --target-platform android-arm64,android-arm
echo.

echo ✅ Build completed!
echo 📱 APK files are in: build\app\outputs\flutter-apk\
echo.

echo 📊 APK sizes:
for %%f in (build\app\outputs\flutter-apk\*.apk) do (
    echo %%~nxf: %%~zf bytes
)
echo.

echo 🎉 Optimized APK ready for deployment!
pause
