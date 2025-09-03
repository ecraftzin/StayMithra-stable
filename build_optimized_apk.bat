@echo off
echo Building optimized APK with smallest size...

echo.
echo Step 1: Cleaning previous builds...
flutter clean

echo.
echo Step 2: Getting dependencies...
flutter pub get

echo.
echo Step 3: Building optimized release APK...
flutter build apk --release --shrink --obfuscate --split-debug-info=build/debug-info --target-platform android-arm64 --tree-shake-icons --dart-define=flutter.inspector.structuredErrors=false

echo.
echo Step 4: Building split APKs for even smaller size...
flutter build apk --release --shrink --obfuscate --split-debug-info=build/debug-info --split-per-abi --target-platform android-arm64,android-arm

echo.
echo Build complete! Check the following locations:
echo - Universal APK: build\app\outputs\flutter-apk\app-release.apk
echo - Split APKs: build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
echo - Split APKs: build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk

echo.
echo APK sizes:
for %%f in (build\app\outputs\flutter-apk\*.apk) do (
    echo %%~nxf: %%~zf bytes
)

pause
