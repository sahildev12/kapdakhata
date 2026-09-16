<p align="center">
  <img src="logos/android-chrome-512x512.png" alt="KapdaKhata logo" width="120" />
</p>

<h1 align="center">KapdaKhata</h1>

<p align="center">
  <strong>Manage • Sell • Grow</strong><br/>
  A simple clothing shop management app for shop owners.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0.0-purple" alt="Version 1.0.0" />
  <img src="https://img.shields.io/badge/platform-Android-green" alt="Android" />
  <img src="https://img.shields.io/badge/built%20with-Flutter-7132F5" alt="Flutter" />
</p>

---

## About

**KapdaKhata** helps clothing shop owners manage day-to-day business without complicated accounting software.

**Kapda** = clothing · **Khata** = business record

Track products, record sales, monitor expenses, and view monthly profit/loss — all from your phone, with data stored locally on the device.

## Features

| Area | What you can do |
|------|-----------------|
| **Home** | Monthly dashboard, net profit, sales summary, quick actions |
| **Products** | Add/edit products, photos, stock, categories, low-stock alerts |
| **Sell** | Record sales with custom item suggestions and auto profit calculation |
| **Expenses** | Track business expenses by category with date filters |
| **Reports** | Monthly trends, expense breakdown, top products |
| **More** | Backup/restore, CSV export, theme (light/dark/system), sample data |
| **Settings** | Shop profile, categories, sale suggestions, notifications threshold |

## Screenshots

> Add device screenshots here after your first install.

## Requirements

- **Android** 5.0+ (API 21+)
- **Flutter** 3.12+ for development
- **Dart** 3.12+

## Install (Release APK)

Download or build the release APK:

```bash
flutter build apk --release
```

The signed debug-key release APK is generated at:

```
build/app/outputs/flutter-apk/app-release.apk
```

Install on a connected device:

```bash
flutter install --release
```

## Development

### Setup

```bash
git clone https://github.com/sahildev12/kapdakhata.git
cd kapdakhata
flutter pub get
dart run build_runner build
```

### Run

```bash
flutter run
```

### Test & analyze

```bash
flutter analyze
flutter test
```

### App icon

Icons are generated from `logos/android-chrome-512x512.png`:

```bash
dart run flutter_launcher_icons
```

## Tech Stack

- **Flutter** + **Riverpod** (state management)
- **Drift** + **SQLite** (local database)
- **GoRouter** (navigation)
- **Google Fonts** (IBM Plex Sans)

## Project Structure

```
lib/
├── core/          # Theme, router, widgets, utils
├── database/      # Drift schema & queries
├── features/      # Home, products, sales, expenses, reports, settings, more
└── shared/        # Providers, repositories, services
```

## Version History

### 1.0.0 (First Release)

- Shop dashboard with monthly metrics
- Product, sales, and expense management
- Reports and CSV export
- Local backup, restore, and daily auto-backup
- Custom sale item suggestions
- Low-stock notifications
- Light / dark / system theme

## Permissions

| Permission | Used for |
|------------|----------|
| Camera | Product photo capture only (requested when needed) |

## License

Private project — all rights reserved.

## Author

Built for clothing shop owners who want a simple, mobile-first business record app.
