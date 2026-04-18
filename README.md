# ShieldX

**Smart DNS Protection**

ShieldX is a premium cross-platform mobile application that helps you browse smarter with essential digital tools. Built with Flutter for Android (API 23+) and iOS.

## Features

### Utilities
- **Text Formatter** — Format and style text with ease
- **Hashtag Generator** — Discover trending hashtags
- **Content Scheduler** — Plan your content calendar
- **Analytics Dashboard** — Track engagement metrics
- **Link Shortener** — Shorten URLs for clean sharing
- **Template Hub** — Access content templates

### Technical
- Clean, minimal design with dark & light mode support
- Premium UI with smooth animations
- Session-based access
- Local data storage — privacy-first approach
- Cross-platform: Android (API 23+) and iOS

## Architecture

```
lib/
  core/         — Constants, themes, utilities
  data/         — Models, repositories, local storage
  domain/       — Entities, use cases
  presentation/ — Screens, widgets, state management
  services/     — Platform services
```

State management via **Provider** pattern.

## Getting Started

### Prerequisites
- Flutter SDK ^3.5.0
- Dart SDK ^3.5.0
- Android Studio / Xcode

### Installation

```bash
git clone https://github.com/Shivpvtltd/CT.git
cd CT
flutter pub get
flutter run
```

## Building

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## CI/CD

GitHub Actions workflows:
- `.github/workflows/build_android.yml` — APK & AAB
- `.github/workflows/build_ios.yml` — IPA

Trigger with version tags:
```bash
git tag v1.0.0
git push origin v1.0.0
```

## Privacy

- No browsing data collection
- No traffic interception beyond DNS resolution
- Only trusted, public DNS providers used
- All processing is local to the device
- Data stays on your device — we don't collect anything

## License

Proprietary — All rights reserved.

## Version

Current: v1.0.0

---

Built with Flutter. Designed for a smoother digital experience.
