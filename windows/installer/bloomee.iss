; Inno Setup script for BloomeeTunes (Windows x64, per-user install)
; Build:  iscc /DMyAppVersion=<ver> windows\installer\bloomee.iss
; Or run windows\installer\build_installer.ps1 from the repo root.

#ifndef MyAppVersion
  #define MyAppVersion "0.0.0"
#endif

#ifndef SourceDir
  #define SourceDir "..\..\build\windows\x64\runner\Release"
#endif

#ifndef OutputDir
  #define OutputDir "..\..\build\windows\x64\installer"
#endif

#define MyAppName       "Bloomee"
#define MyAppPublisher  "BloomeeTunes"
#define MyAppURL        "https://github.com/HemantKArya/BloomeeTunes"
#define MyAppExeName    "Bloomee.exe"

[Setup]
; Stable GUID — must never change once published, used to detect prior installs.
AppId={{5E8A4C3D-1B7F-4A9E-9C2D-8F6A3E1B7C4D}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
AppUpdatesURL={#MyAppURL}/releases

; Per-user install — no UAC, installs into %LocalAppData%\Programs\Bloomee.
PrivilegesRequired=lowest
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
DisableDirPage=no
AllowNoIcons=yes

; x64 only (Flutter Windows targets x64).
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

LicenseFile=..\..\LICENSE
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName} {#MyAppVersion}

WizardStyle=modern
Compression=lzma2/ultra64
SolidCompression=yes
LZMAUseSeparateProcess=yes

OutputDir={#OutputDir}
OutputBaseFilename=bloomee_tunes_windows_x64_v{#MyAppVersion}_setup

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Pull the entire Flutter Windows release bundle: the exe, Flutter engine DLL,
; Rust FFI DLL, media_kit native libs, audio_service_win, discord_game_sdk,
; and the data/ folder with assets/fonts/icudtl.
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent
