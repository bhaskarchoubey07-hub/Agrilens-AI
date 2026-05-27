# PowerShell script to download and configure a portable Flutter & Java environment, then build the APK
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue" # Speeds up downloads significantly by suppressing progress bars

$workDir = "c:\Users\bhask\OneDrive\Documents\agritech"
$toolsDir = Join-Path $workDir "dev_tools"

if (-not (Test-Path $toolsDir)) {
    New-Item -ItemType Directory -Path $toolsDir | Out-Null
    Write-Host "Created tools directory: $toolsDir"
}

# 1. Setup Java JDK 17 (Microsoft OpenJDK stable zip)
$jdkDir = Join-Path $toolsDir "jdk"
if (-not (Test-Path $jdkDir)) {
    Write-Host "Downloading portable Java JDK 17 (~140MB)..."
    $jdkUrl = "https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jdk/hotspot/normal/eclipse"
    $jdkZip = Join-Path $toolsDir "jdk.zip"
    & curl.exe -L -o $jdkZip $jdkUrl
    Write-Host "Extracting JDK..."
    Expand-Archive -Path $jdkZip -DestinationPath $toolsDir
    
    # The zip contains a folder like 'jdk-17.x.x', rename it to 'jdk'
    $extractedFolder = Get-ChildItem -Path $toolsDir -Directory -Filter "jdk-17*" | Select-Object -First 1
    if ($extractedFolder) {
        Rename-Item -Path $extractedFolder.FullName -NewName "jdk"
    }
    Remove-Item $jdkZip
    Write-Host "Java JDK 17 configured."
} else {
    Write-Host "Java JDK 17 already configured."
}

# 2. Setup Flutter SDK (Stable Windows zip)
$flutterDir = Join-Path $toolsDir "flutter"
if (-not (Test-Path $flutterDir)) {
    Write-Host "Downloading portable Flutter SDK (~950MB). This may take a minute..."
    $flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.22.1-stable.zip"
    $flutterZip = Join-Path $toolsDir "flutter.zip"
    & curl.exe -L -o $flutterZip $flutterUrl
    Write-Host "Extracting Flutter SDK... (This can take a couple of minutes)"
    Expand-Archive -Path $flutterZip -DestinationPath $toolsDir
    Remove-Item $flutterZip
    Write-Host "Flutter SDK configured."
} else {
    Write-Host "Flutter SDK already configured."
}

# 3. Configure Path variables for the current shell session
Write-Host "Configuring session environment paths..."
$env:JAVA_HOME = $jdkDir
$env:ANDROID_HOME = "C:\Users\bhask\AppData\Local\Android\Sdk"

# Prepend JDK bin and Flutter bin to the path
$env:PATH = "$jdkDir\bin;$flutterDir\bin;" + $env:PATH

# Skipping flutter doctor to avoid hang during background execution

# 4. Compile the AgriLens AI Android application
Write-Host "========================================================="
Write-Host "Starting compilation of AgriLens AI APK..."
Write-Host "========================================================="

cd "$workDir\agrilens_app"
& flutter clean
& flutter pub get
& flutter build apk --debug -v

Write-Host "========================================================="
Write-Host "BUILD SUCCESS! APK generated at:"
Write-Host "$workDir\agrilens_app\build\app\outputs\flutter-apk\app-debug.apk"
Write-Host "========================================================="
