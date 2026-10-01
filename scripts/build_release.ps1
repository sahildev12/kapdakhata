# Builds a release APK and saves it to releases/KapdaKhata-v{version}.apk
$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $root

$pubspec = Get-Content (Join-Path $root "pubspec.yaml") -Raw
if ($pubspec -notmatch 'version:\s*([\d.]+)\+(\d+)') {
  throw "Could not read version from pubspec.yaml"
}
$version = $Matches[1]

Write-Host "Building KapdaKhata v$version..."
flutter build apk --release

$buildApk = Join-Path $root "build\app\outputs\flutter-apk\app-release.apk"
if (-not (Test-Path $buildApk)) {
  throw "Build failed: APK not found at $buildApk"
}

$releasesDir = Join-Path $root "releases"
$releaseApk = Join-Path $releasesDir "KapdaKhata-v$version.apk"
New-Item -ItemType Directory -Force -Path $releasesDir | Out-Null
Copy-Item $buildApk $releaseApk -Force
Remove-Item $buildApk -Force

Write-Host ""
Write-Host "Release APK saved to:"
Write-Host "  $releaseApk"
Write-Host ""
Write-Host "Temporary build output removed from build/app/outputs/flutter-apk/"
