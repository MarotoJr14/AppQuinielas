@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "PROJECT_DIR=%%~fI"

for /f "tokens=2 delims=:" %%A in ('findstr /R /C:"^[ ]*version:" "%PROJECT_DIR%\pubspec.yaml"') do set "VERSION_LINE=%%A"
for /f "tokens=1 delims=+ " %%A in ("%VERSION_LINE%") do set "VERSION=%%A"

if not defined VERSION (
    echo ERROR: No se ha podido obtener la version de pubspec.yaml.
    exit /b 1
)

set "APK_SOURCE=%PROJECT_DIR%\build\app\outputs\flutter-apk\app-release.apk"
set "APK_DESTINATION=%SCRIPT_DIR%app_quinielas-%VERSION%.apk"

echo BUILD RELEASE - APP QUINIELAS ANDROID
echo Version: %VERSION%
echo.

pushd "%PROJECT_DIR%" || goto error
set "PUSHED_DIR=1"

echo Limpiando proyecto...
call flutter clean || goto error

echo Obteniendo dependencias...
call flutter pub get || goto error

echo Construyendo APK...
call flutter build apk --release || goto error

if not exist "%APK_SOURCE%" (
    echo ERROR: No se ha encontrado el APK generado.
    goto error
)

copy /Y "%APK_SOURCE%" "%APK_DESTINATION%" >nul || goto error

popd
echo.
echo APK generado: %APK_DESTINATION%
exit /b 0

:error
if defined PUSHED_DIR popd
echo.
echo ERROR DURANTE LA COMPILACION
exit /b 1
