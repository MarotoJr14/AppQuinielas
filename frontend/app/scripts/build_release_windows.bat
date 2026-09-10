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

set "RELEASE_DIR=%PROJECT_DIR%\build\windows\x64\runner\Release"
set "EXE_SOURCE=%RELEASE_DIR%\app_quinielas.exe"
set "INSTALLER_SCRIPT=%SCRIPT_DIR%app_quinielas.iss"
set "INSTALLER_DESTINATION=%SCRIPT_DIR%app_quinielas-%VERSION%.exe"

echo BUILD RELEASE - APP QUINIELAS WINDOWS
echo Version: %VERSION%
echo.

pushd "%PROJECT_DIR%" || goto error
set "PUSHED_DIR=1"

echo Limpiando proyecto...
call flutter clean || goto error

echo Obteniendo dependencias...
call flutter pub get || goto error

echo Construyendo EXE...
call flutter build windows --release || goto error

if not exist "%EXE_SOURCE%" (
    echo ERROR: No se ha encontrado el paquete Release de Windows.
    goto error
)

if not exist "%INSTALLER_SCRIPT%" (
    echo ERROR: No se ha encontrado el archivo de Inno Setup.
    goto error
)

set "ISCC="
for %%I in (ISCC.exe) do set "ISCC=%%~$PATH:I"
if not defined ISCC if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if not defined ISCC if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles%\Inno Setup 6\ISCC.exe"

if not defined ISCC (
    echo ERROR: Inno Setup 6 no esta instalado o ISCC.exe no esta disponible.
    echo Instala Inno Setup 6 y vuelve a ejecutar este script.
    goto error
)

echo Creando instalador con Inno Setup...
call "%ISCC%" "/DAppVersion=%VERSION%" "/DSourceDir=%RELEASE_DIR%" "/DOutputDir=%SCRIPT_DIR%" "%INSTALLER_SCRIPT%" || goto error

popd
echo.
echo Instalador generado: %INSTALLER_DESTINATION%
exit /b 0

:error
if defined PUSHED_DIR popd
echo.
echo ERROR DURANTE LA COMPILACION
exit /b 1
