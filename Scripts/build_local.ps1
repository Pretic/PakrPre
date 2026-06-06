param(
    [Parameter(Mandatory = $true)]
    [string]$AppUrl,

    [Parameter(Mandatory = $true)]
    [string]$AppName,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*){1,}$')]
    [string]$PackageName,

    [string]$VersionName = "1.0.0",

    [ValidateSet("generated", "url")]
    [string]$IconMode = "generated",

    [string]$IconUrl = "",

    [ValidatePattern('^#?[0-9a-fA-F]{6}$')]
    [string]$IconColor = "#BF3EFF",

    [switch]$NoScreenshot,

    [switch]$ShowDisclaimer,

    [switch]$Install
)

$ErrorActionPreference = "Stop"

function Replace-InFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Old,
        [Parameter(Mandatory = $true)][string]$New
    )
    $text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    $text = $text.Replace($Old, $New)
    Set-Content -LiteralPath $Path -Value $text -Encoding UTF8
}

function Escape-XmlText {
    param([string]$Value)
    return $Value.Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace('"', "&quot;").Replace("'", "&apos;")
}

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$buildId = Get-Date -Format "yyyyMMdd-HHmmss"
$workDir = Join-Path $root "build\local-work\$buildId"
New-Item -ItemType Directory -Path $workDir -Force | Out-Null

Get-ChildItem -LiteralPath $root -Force |
    Where-Object { $_.Name -notin @(".git", "build") } |
    ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $workDir -Recurse -Force
    }

$appBuild = Join-Path $workDir "app\build.gradle"
$manifest = Join-Path $workDir "app\src\main\AndroidManifest.xml"
$strings = Join-Path $workDir "app\src\main\res\values\strings.xml"
$mainActivity = Join-Path $workDir "app\src\main\java\com\webviewapp\MainActivity.kt"
$splashActivity = Join-Path $workDir "app\src\main\java\com\webviewapp\SplashActivity.kt"
$mainLayout = Join-Path $workDir "app\src\main\res\layout\activity_main.xml"

$versionCode = [int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$noScreenshotValue = if ($NoScreenshot) { "true" } else { "false" }
$showDisclaimerValue = if ($ShowDisclaimer) { "true" } else { "false" }
$appNameXml = Escape-XmlText $AppName

Replace-InFile $mainActivity "{{APP_URL}}" $AppUrl
Replace-InFile $mainActivity "{{NO_SCREENSHOT}}" $noScreenshotValue
Replace-InFile $splashActivity "{{SHOW_DISCLAIMER}}" $showDisclaimerValue
Replace-InFile $manifest "{{APP_PACKAGE}}" $PackageName
Replace-InFile $appBuild "{{APP_PACKAGE}}" $PackageName
Replace-InFile $strings "{{APP_NAME}}" $appNameXml
Replace-InFile $manifest "{{APP_NAME}}" $appNameXml
Replace-InFile $appBuild "{{VERSION_NAME}}" $VersionName
Replace-InFile $appBuild "{{VERSION_CODE}}" ([string]$versionCode)

$packagePath = $PackageName.Replace(".", "\")
$sourceDir = Join-Path $workDir "app\src\main\java\com\webviewapp"
$targetDir = Join-Path $workDir "app\src\main\java\$packagePath"
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
Get-ChildItem -LiteralPath $sourceDir -Filter "*.kt" | ForEach-Object {
    Replace-InFile $_.FullName "package com.webviewapp" "package $PackageName"
    Move-Item -LiteralPath $_.FullName -Destination (Join-Path $targetDir $_.Name) -Force
}
Replace-InFile $mainLayout "com.webviewapp" $PackageName

$env:ICON_MODE = $IconMode
$env:ICON_URL = $IconUrl
$env:ICON_COLOR = $IconColor
$env:APP_NAME = $AppName
$env:PACKAGE_NAME = $PackageName

Push-Location $workDir
try {
    $python = Get-Command python -ErrorAction SilentlyContinue
    if (-not $python) {
        throw "Python was not found in PATH. Install Python 3 and Pillow before building locally."
    }
    & python Scripts\process_icon.py
    if ($LASTEXITCODE -ne 0) { throw "Icon processing failed." }

    & .\gradlew.bat assembleDebug --no-daemon
    if ($LASTEXITCODE -ne 0) { throw "Gradle build failed." }

    $apks = Get-ChildItem -Path "app\build\outputs\apk" -Recurse -Filter "*.apk"
    if (-not $apks) { throw "Build finished but no APK was found." }

    Write-Host ""
    Write-Host "APK output:"
    $apks | ForEach-Object { Write-Host "  $($_.FullName)" }

    if ($Install) {
        $adb = Get-Command adb -ErrorAction SilentlyContinue
        if (-not $adb) { throw "adb was not found in PATH. Install Android Platform Tools or open Android Studio first." }
        $abi = (& adb shell getprop ro.product.cpu.abi).Trim()
        $targetApk = $apks | Where-Object { $_.Name -like "*$abi*" } | Select-Object -First 1
        if (-not $targetApk) { $targetApk = $apks | Select-Object -First 1 }
        & adb install -r $targetApk.FullName
    }
}
finally {
    Pop-Location
}
