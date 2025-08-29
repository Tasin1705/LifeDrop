@echo off
echo Clearing system memory and rebuilding Flutter app...
echo.

echo Step 1: Stopping all Gradle daemons...
cd android
gradlew --stop
cd ..

echo Step 2: Cleaning Flutter project...
flutter clean

echo Step 3: Getting dependencies...
flutter pub get

echo Step 4: Running app with limited memory...
flutter run

pause
