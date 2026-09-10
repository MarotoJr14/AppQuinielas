#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

#ifndef SourceDir
  #define SourceDir "..\build\windows\x64\runner\Release"
#endif

#ifndef OutputDir
  #define OutputDir "."
#endif

[Setup]
AppId={{B2C21F0D-30A3-4FA1-8D8B-DBBA77E46A87}
AppName=App Quinielas
AppVersion={#AppVersion}
AppPublisher=App Quinielas
DefaultDirName={autopf}\App Quinielas
DefaultGroupName=App Quinielas
UninstallDisplayIcon={app}\app_quinielas.exe
OutputDir={#OutputDir}
OutputBaseFilename=app_quinielas-{#AppVersion}
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
WizardStyle=modern

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\App Quinielas"; Filename: "{app}\app_quinielas.exe"
Name: "{autodesktop}\App Quinielas"; Filename: "{app}\app_quinielas.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Crear un acceso directo en el escritorio"; GroupDescription: "Accesos directos adicionales:"

[Run]
Filename: "{app}\app_quinielas.exe"; Description: "Iniciar App Quinielas"; Flags: nowait postinstall skipifsilent
