<p align="center">
  <img src="logos/android-chrome-512x512.png" alt="KapdaKhata logo" width="120" />
</p>

<h1 align="center">KapdaKhata</h1>

<p align="center">
  <strong>Manage • Sell • Grow</strong><br/>
  Simple clothing shop management for shop owners.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0.1-purple" alt="Version 1.0.1" />
  <img src="https://img.shields.io/badge/platform-Android-green" alt="Android" />
  <img src="https://img.shields.io/badge/Flutter-3.12+-7132F5" alt="Flutter" />
</p>

---

## About

**KapdaKhata** helps clothing shop owners track products, sales, expenses, and monthly profit — without complicated accounting software. All data is stored locally on your device.

| | |
|---|---|
| **Kapda** | clothing |
| **Khata** | business record |

## Features

- **Dashboard** — monthly profit, sales summary, recent activity
- **Products** — stock, photos, categories, low-stock alerts
- **Sell** — multi-item sales, custom suggestions, auto profit
- **Expenses** — categories, date filters, detail views
- **Reports** — trends, expense breakdown, top products
- **Backup** — local backup, restore, daily auto-backup, CSV export
- **Settings** — shop profile, themes, notifications, sale suggestions

## Download

**Latest release: v1.0.1**

Build the APK locally:

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

Or install directly on a connected device:

```bash
flutter install --release
```

## Development

### Prerequisites

- Flutter 3.12+
- Dart 3.12+
- Android SDK (for Android builds)

### Setup

```bash
git clone https://github.com/sahildev12/kapdakhata.git
cd kapdakhata
flutter pub get
dart run build_runner build
flutter run
```

### Quality checks

```bash
flutter analyze
flutter test
```

### Regenerate app icons

```bash
dart run flutter_launcher_icons
```

Source icon: `logos/android-chrome-512x512.png`

## Tech stack

| Layer | Technology |
|-------|------------|
| UI | Flutter, Material 3 |
| State | Riverpod |
| Database | Drift + SQLite |
| Navigation | GoRouter |
| Fonts | IBM Plex Sans (Google Fonts) |

## Project layout

```
lib/
├── core/       # Theme, router, shared widgets
├── database/   # Drift schema and queries
├── features/   # Screens (home, products, sales, …)
└── shared/     # Providers, repositories, services
logos/          # App icon and branding assets
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

### v1.0.1 (latest)

- Fix clear all data not updating the UI
- Prevent demo data from reloading after clear

## Permissions

| Permission | Why |
|------------|-----|
| Camera | Product photos only (requested when needed) |

## License

Private project — all rights reserved.
