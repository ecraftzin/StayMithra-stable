# StayMithra APK Build Script
# This script builds the APK and copies it to the expected Flutter location

Write-Host "🚀 Building StayMithra APK..." -ForegroundColor Green

# Clean previous build
Write-Host "🧹 Cleaning previous build..." -ForegroundColor Yellow
flutter clean
flutter pub get

# Build debug APK
Write-Host "🔨 Building debug APK..." -ForegroundColor Yellow
flutter build apk --debug

# Build release APK
Write-Host "🔨 Building release APK..." -ForegroundColor Yellow
flutter build apk --release

# Create Flutter expected directory structure
Write-Host "📁 Creating Flutter directory structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "build\app\outputs\flutter-apk" | Out-Null

# Copy APKs to expected location
Write-Host "📋 Copying APKs to Flutter expected location..." -ForegroundColor Yellow
Copy-Item "android\app\build\outputs\flutter-apk\*" "build\app\outputs\flutter-apk\" -Force

# Display results
Write-Host "✅ Build completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📱 APK Files Generated:" -ForegroundColor Cyan
Get-ChildItem build\app\outputs\flutter-apk\ | Format-Table Name, @{Name="Size (MB)"; Expression={[math]::Round($_.Length/1MB, 2)}} -AutoSize

Write-Host "📍 APK Locations:" -ForegroundColor Cyan
Write-Host "  Debug APK:   build\app\outputs\flutter-apk\app-debug.apk" -ForegroundColor White
Write-Host "  Release APK: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
Write-Host ""
Write-Host "🎉 Ready for installation and testing!" -ForegroundColor Green
