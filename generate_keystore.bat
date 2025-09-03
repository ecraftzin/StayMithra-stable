@echo off
echo Generating Release Keystore for StayMithra App...
echo.
echo This will create a release keystore for production builds.
echo Please provide the following information when prompted:
echo.
echo - Keystore password (remember this!)
echo - Key alias: staymithra-release
echo - Key password (can be same as keystore password)
echo - Your name
echo - Organization: StayMithra
echo - City/Location
echo - State/Province
echo - Country code (e.g., US, IN, etc.)
echo.
pause

keytool -genkey -v -keystore android\app\staymithra-release.keystore -alias staymithra-release -keyalg RSA -keysize 2048 -validity 10000

echo.
echo Keystore generated successfully!
echo.
echo IMPORTANT: 
echo 1. Keep the keystore file safe - you'll need it for all future app updates
echo 2. Remember your passwords - you cannot recover them if lost
echo 3. The keystore is saved at: android\app\staymithra-release.keystore
echo.
echo Next steps:
echo 1. Create key.properties file with your keystore details
echo 2. Update build.gradle to use the release keystore
echo.
pause
