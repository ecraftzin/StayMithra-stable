@echo off
echo 🚀 Building LITE VERSION StayMithra APK (Target: 20-25 MB)...
echo ⚠️  This version temporarily removes video functionality for size testing
echo.

echo 📦 Creating backup of current pubspec.yaml...
copy pubspec.yaml pubspec_backup.yaml

echo 📝 Creating lite version pubspec.yaml...
powershell -Command "(Get-Content pubspec.yaml) -replace '  video_player: \^2\.8\.1', '  # video_player: ^2.8.1 # REMOVED FOR LITE VERSION' -replace '  chewie: \^1\.7\.4', '  # chewie: ^1.7.4 # REMOVED FOR LITE VERSION' -replace '  file_picker: \^10\.3\.2', '  # file_picker: ^10.3.2 # REMOVED FOR LITE VERSION' | Set-Content pubspec_lite.yaml"

echo 📝 Using lite pubspec.yaml...
copy pubspec_lite.yaml pubspec.yaml

echo 📦 Cleaning previous builds...
flutter clean

echo 📥 Getting dependencies for lite version...
flutter pub get

echo 🔧 Building ultra-optimized LITE APK...
flutter build apk --release ^
  --shrink ^
  --obfuscate ^
  --split-debug-info=build/debug-info ^
  --target-platform android-arm64 ^
  --tree-shake-icons

echo.
echo 📊 APK sizes:
for %%f in (build\app\outputs\flutter-apk\*.apk) do (
    set /a size=%%~zf/1024/1024
    echo %%~nxf: !size! MB
)

echo.
echo 🔄 Restoring original pubspec.yaml...
copy pubspec_backup.yaml pubspec.yaml
del pubspec_lite.yaml
del pubspec_backup.yaml

echo.
echo ✅ Lite version build completed!
echo ⚠️  Note: This version has video functionality disabled
echo 🎯 Check if size is closer to 20-25 MB target
pause
