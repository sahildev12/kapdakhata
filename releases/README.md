# Releases

All Android release APKs are saved in this folder.

## File naming

```
KapdaKhata-v{version}.apk
```

Example: `KapdaKhata-v1.0.1.apk`

## Build a release

**Windows (PowerShell):**

```powershell
.\scripts\build_release.ps1
```

**macOS / Linux:**

```bash
chmod +x scripts/build_release.sh
./scripts/build_release.sh
```

The script builds the APK, copies it here, and removes the temporary file from `build/app/outputs/flutter-apk/`.

> APK files in this folder are not committed to git. Upload them to GitHub Releases when publishing.
