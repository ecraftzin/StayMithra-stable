@echo off
echo 🚀 Building MINIMAL SIZE StayMithra APK (Target: 20-25 MB)...
echo.

echo 📦 Cleaning previous builds...
flutter clean
echo.

echo 📥 Getting dependencies...
flutter pub get
echo.

echo 🔧 Building ultra-optimized release APK...
echo ⚡ Using maximum size optimization settings...
flutter build apk --release ^
  --shrink ^
  --obfuscate ^
  --split-debug-info=build/debug-info ^
  --target-platform android-arm64 ^
  --tree-shake-icons ^
  --dart-define=flutter.inspector.structuredErrors=false ^
  --dart-define=dart.vm.product=true ^
  --no-pub ^
  --no-tree-shake-icons=false

echo.

echo ✅ Build completed!
echo 📱 APK files are in: build\app\outputs\flutter-apk\
echo.

echo 📊 APK sizes:
for %%f in (build\app\outputs\flutter-apk\*.apk) do (
    set /a size=%%~zf/1024/1024
    echo %%~nxf: !size! MB
)
echo.

echo 🎯 Target achieved if APK is 20-25 MB!
echo 🎉 Minimal APK ready for deployment!
pause
