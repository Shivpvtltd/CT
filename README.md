# 🛡️ DNSGuard — Ad Protection, Simplified

> One-tap DNS-based ad blocking. 6-hour session system. Premium UI. Zero VPN slowdown.

---

## 📱 Features

| Feature | Details |
|---|---|
| **One-Tap Toggle** | Instant ON/OFF, <1 second switch |
| **6-Hour Sessions** | Auto-expires, notifies on end |
| **4 DNS Providers** | AdGuard, NextDNS, Control D, Alternate DNS |
| **Auto Fallback** | Switches provider if one fails |
| **Quick Settings Tile** | Toggle without opening app (Android) |
| **Dark + Light Mode** | Full theme support |
| **Smart Notifications** | Only on session expire — not annoying |
| **Onboarding Flow** | 3-screen guide for new users |

---

## 🌐 DNS Providers

| Mode | Provider | Hostname |
|---|---|---|
| 🛡️ Balanced | AdGuard DNS | `dns.adguard-dns.com` |
| ⚡ Strong | NextDNS | `dns.nextdns.io` |
| 🧠 Smart | Control D | `freedns.controld.com` |
| 🌿 Lite | Alternate DNS | `dns.alternate-dns.com` |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.13.0`
- Android Studio / Xcode
- Java 17

### Setup

```bash
git clone https://github.com/YOUR_USERNAME/dnsguard.git
cd dnsguard
flutter pub get
flutter run
```

### Build APK locally

```bash
# Debug APK
flutter build apk --debug

# Release APK (split per ABI — smaller size)
flutter build apk --release --split-per-abi

# Release AAB (for Play Store)
flutter build appbundle --release
```

---

## ⚙️ GitHub Actions CI/CD

The repo includes two workflows:

| Workflow | Trigger | Output |
|---|---|---|
| `build-android.yml` | Push to `main`, PR, tag `v*.*.*` | APK + AAB |
| `build-ios.yml` | Tag `v*.*.*`, manual | IPA |

### Required GitHub Secrets (for signed release)

Go to **Settings → Secrets → Actions** and add:

| Secret | Description |
|---|---|
| `KEYSTORE_BASE64` | Base64-encoded `.jks` keystore |
| `KEYSTORE_PASSWORD` | Keystore password |
| `KEY_ALIAS` | Key alias |
| `KEY_PASSWORD` | Key password |

### Generate a keystore

```bash
keytool -genkey -v \
  -keystore dnsguard-release.jks \
  -alias dnsguard \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

# Encode to base64 (copy output to KEYSTORE_BASE64 secret)
base64 -i dnsguard-release.jks | pbcopy   # macOS
base64 dnsguard-release.jks              # Linux
```

### Trigger a release

```bash
git tag v1.0.0
git push origin v1.0.0
```

This automatically:
1. Runs tests
2. Builds signed APK (arm64, arm32, universal)
3. Builds signed AAB
4. Creates a GitHub Release with download links

---

## 📂 Project Structure

```
dnsguard/
├── lib/
│   ├── main.dart                    # App entry
│   ├── core/
│   │   ├── constants/
│   │   │   └── dns_providers.dart   # DNS configs & constants
│   │   └── services/
│   │       ├── dns_service.dart     # DNS switching logic
│   │       ├── notification_service.dart
│   │       └── providers.dart       # Riverpod state
│   ├── features/
│   │   ├── home/
│   │   │   └── home_screen.dart    # Main toggle UI
│   │   ├── onboarding/
│   │   │   └── onboarding_screen.dart
│   │   └── settings/
│   │       └── settings_screen.dart
│   └── shared/
│       └── theme/
│           └── app_theme.dart       # Dark/light themes
├── android/
│   └── app/
│       ├── src/main/kotlin/.../
│       │   ├── MainActivity.kt      # MethodChannel + DNS
│       │   └── DnsGuardTileService.kt # Quick Settings Tile
│       └── src/main/res/
├── ios/Runner/Info.plist
└── .github/workflows/
    ├── build-android.yml
    └── build-ios.yml
```

---

## 🔐 Privacy & Compliance

- ✅ No traffic interception beyond DNS queries
- ✅ No user data collection
- ✅ Only trusted, public DNS providers
- ✅ Play Store policy compliant
- ⚠️ "Blocks **most** ads. Some apps may require ads to function."

---

## 📌 How DNS Ad Blocking Works

```
Normal:  App → DNS → Ad server IP → Ads load ❌
DNSGuard: App → AdGuard DNS → NXDOMAIN → Ads blocked ✅
```

DNS-level blocking:
- Works system-wide (apps + browsers)
- No battery drain (no VPN tunnel)
- No traffic inspection
- Instant switching

---

## 🏷️ Versioning

Follows **Semantic Versioning**: `MAJOR.MINOR.PATCH`

- `v1.0.0` — Initial release
- `v1.1.0` — New DNS providers / features
- `v1.0.1` — Bug fixes

---

## 📄 License

MIT License. See [LICENSE](LICENSE).

---

> DNSGuard — Ad Protection, Simplified  
> Blocks most ads. Some apps may require ads to function.
