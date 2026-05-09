# AlternativeStore — MarketplaceKit Demo

> **Talk:** "Как легально опубликоваться вне App Store" · [Mobius 2026](https://mobiusconf.com)  
> **Author:** Sergei Vikhliaev · Lead iOS Developer at [Onside](https://onside.io)

A minimal, production-structured iOS app demonstrating every layer of an **Alternative App Marketplace** built on Apple's `MarketplaceKit`.

Runs entirely on mock data out of the box — no Apple keys, no server, no configuration needed.  
Swap in your credentials and a real backend → it becomes a live marketplace.

---

## What You'll See

The app ships with **6 fictional apps** and two install button variants on each detail screen:

| Button | Behaviour |
|--------|-----------|
| **Custom button** (overlay pattern) | Your own design; a transparent `ActionButton` captures the tap |
| **Standard `ActionButton`** | Apple's system button, no custom styling |

On the **Simulator**, tapping either button triggers a step-by-step animated log that mirrors the real `confirmInstall` flow. Every log entry is written **both to the on-screen list and to the Xcode Debug Console** via `os.Logger`.

---

## How the Install Flow Works

```
User taps ActionButton
        ↓
MarketplaceKit shows system confirmation sheet
        ↓
System calls confirmInstall { } closure
        ↓
Your business logic (auth, eligibility, …)
        ↓
GET /versions/{appleVersionId}/install  →  install_verification_token (JWT)
        ↓
return .confirmed(installVerificationToken:)
        ↓
MarketplaceKit downloads and installs the .adp package
```

The JWT is signed by **your backend** with the private key registered in App Store Connect.  
MarketplaceKit verifies it cryptographically — this is Apple's anti-piracy mechanism.

---

## Quick Start

```bash
open AlternativeStore_MobiusDEMO.xcodeproj
```

1. Select any **iPhone Simulator** and press **Cmd+R**
2. Tap any app in the list
3. Tap **Install** → watch the flow animate on screen and stream to the console

Requirements: **Xcode 26+** · **iOS 26 SDK** · **Swift 6**

---

## Project Structure

```
AlternativeStore_MobiusDEMO/
├── Configuration/
│   └── MarketplaceConfiguration.swift      ← Single source of truth: URLs, keys, mock toggle
│
├── Models/
│   ├── AppModel.swift                       ← App catalog DTO (mirrors a typical backend response)
│   └── AppInstallMetadata.swift             ← { install_verification_token } response model
│
├── Services/
│   ├── Protocols/
│   │   ├── CatalogProvider.swift            ← fetchApps() — mock or network
│   │   ├── InstallationConfigurationProvider.swift
│   │   └── AppLibraryProvider.swift         ← installState / statePublisher
│   │
│   ├── Mock/
│   │   └── MockCatalogProvider.swift        ← 6 hardcoded apps, no network
│   │
│   ├── InstallationSupportService.swift     ← Builds InstallConfiguration + confirmInstall
│   ├── AppLibraryService.swift              ← AppLibrary.current wrapper + simulator stubs
│   └── NetworkService.swift                 ← URLSession client: catalog + install token
│
├── Utilities/
│   └── AppLogger.swift                      ← os.Logger channels (install / network / library)
│
├── ViewModels/
│   ├── FeedViewModel.swift                  ← Catalog loading state machine
│   └── AppDetailViewModel.swift             ← Install state + simulateInstall() flow
│
├── Views/
│   ├── Feed/
│   │   ├── FeedViewController.swift         ← Screen 1: app list
│   │   └── AppCell.swift
│   └── Detail/
│       ├── AppDetailViewController.swift    ← Screen 2: detail + both install buttons
│       └── CustomInstallButton.swift        ← Transparent ActionButton overlay pattern
│
├── Extension/
│   ├── MarketplaceExtensionExample.swift    ← Reference implementation (not compiled)
│   └── WellKnownMarketplaceKit.json         ← Example /.well-known/marketplace-kit config
│
└── Entitlements/
    └── AlternativeStore_MobiusDEMO.entitlements
```

---

## Debug Console

The app uses `os.Logger` with subsystem **`io.demo.alternativestore`**.

### Xcode Debug Console

Filter bar (bottom of Xcode console):
```
subsystem:io.demo.alternativestore
```

### macOS Console.app

```
subsystem:io.demo.alternativestore
```

### Log Categories

| Category  | What it tracks                                                |
|-----------|---------------------------------------------------------------|
| `install` | makeInstallConfiguration, confirmInstall steps, token exchange |
| `network` | Catalog fetch, install token requests and responses           |
| `library` | AppLibrary state transitions: available → installing → installed |

### Example Output (Simulator Install Simulation)

```
[install] ─────── Install Simulation START: Pixel Camera Pro ───────
[install] [1] User tapped Install
[install] [2] confirmInstall() called by MarketplaceKit
[install] [3] Fetching install_verification_token...
[install] [network] fetchInstallToken(appleVersionId: 200001) → mock
[install] [network] fetchInstallToken ← mock token (length: 38)
[install] [4] Token received → .confirmed
[install] [5] Installing...
[install] [6] Install complete ✓
[install] ─────── Install Simulation DONE: Pixel Camera Pro ────────
```

---

## Connect to a Real Backend

Edit `Configuration/MarketplaceConfiguration.swift`:

```swift
enum MarketplaceConfiguration {
    static let baseURL     = URL(string: "https://api.yourstore.com")!
    static let accessToken: String? = "your-auth-token"   // x-access-token header
    static let marketplaceID: Int  = 123_456_789           // from App Store Connect
    static let useMockData = false                          // ← flip this
}
```

Your backend must implement two endpoints:

| Method | Path | Returns |
|--------|------|---------|
| `GET` | `/api/v1/apps` | `[AppModel]` — app catalog |
| `GET` | `/api/v1/versions/{appleVersionId}/install` | `{ "install_verification_token": "eyJ…" }` |

The `install_verification_token` is a **JWT signed with your private key** registered in App Store Connect under your marketplace. MarketplaceKit verifies the signature — never expose the private key in the client.

---

## Required Entitlements

Three entitlements are needed for a production marketplace:

| Entitlement | Purpose |
|-------------|---------|
| `com.apple.developer.marketplace.app-installation` | Required to call `AppLibrary.install()` — the core entitlement |
| `com.apple.developer.in-app-payments` | Accept payment for apps inside the marketplace |
| `com.apple.developer.associated-domains` | Universal Links — install buttons from your website |

Request the marketplace entitlement:  
→ https://developer.apple.com/contact/request/app-marketplace-entitlement

---

## `.well-known/marketplace-kit`

Apple fetches `https://yourdomain.com/.well-known/marketplace-kit` to discover your backend endpoints. Key fields:

| Field | Purpose |
|-------|---------|
| `restore` | Called to restore previously purchased/installed apps |
| `updates.url` | Apple polls this for available app updates |
| `updates.pollingInterval` | Seconds between polls (43200 = 12 h) |
| `license.*` | DRM license management (issue, renew, signing cert, encryption cert) |
| `overridesByAppleItemID` | Separate config for the marketplace app itself |

See `Extension/WellKnownMarketplaceKit.json` for the full format.

---

## Add a MarketplaceExtension Target

`MarketplaceExtension` runs in the background for **automatic app updates** — no user interaction required.

1. **Xcode → File → New → Target → ExtensionKit Extension**
2. In the extension's `Info.plist`:
   ```xml
   <key>EXExtensionPointIdentifier</key>
   <string>com.apple.marketplace.extension</string>
   ```
3. Move `Extension/MarketplaceExtensionExample.swift` into the new target
4. Remove the `#if false` / `#endif` guards
5. Share `NetworkService`, `AppModel`, and `AppInstallMetadata` between targets

The extension implements four methods:

| Method | Purpose |
|--------|---------|
| `additionalHeaders(for:account:)` | Auth headers for Apple → your backend requests |
| `requestFailed(with:)` | Handle 401s; return `true` to retry after token refresh |
| `availableAppVersions(forAppleItemIDs:)` | Tell Apple which versions are available for given apps |
| `automaticUpdates(for:)` | Provide `AutomaticUpdate` objects for installed apps that have updates |

---

## What Won't Work Without Apple Keys

| Feature | Why it fails |
|---------|-------------|
| `ActionButton` tap | Requires a provisioning profile with the marketplace entitlement |
| `AppLibrary.current` | Returns empty data without a registered marketplace ID |
| `confirmInstall` completion | `install_verification_token` must be a valid JWT from your registered backend |
| `MarketplaceExtension` invocation | System only calls extensions from registered marketplaces |

The **Simulator mode** (`useMockData = true`) works around all of these with realistic stubs and a step-by-step animated log.

---

## Availability

| Region | Available since |
|--------|----------------|
| European Union | iOS 17.4 · March 2024 (DMA Article 6(4)) |
| Japan | iOS 17.4 · January 2026 (MSCA) |

---

## Links

- [Apple: Distributing apps in alternative marketplaces](https://developer.apple.com/documentation/appdistribution)
- [Apple: MarketplaceKit documentation](https://developer.apple.com/documentation/marketplacekit)
- [Apple: Notarization for alternative marketplaces](https://developer.apple.com/documentation/appdistribution/notarization-for-apps-distributed-with-alternative-marketplace)
- [Apple: Request marketplace entitlement](https://developer.apple.com/contact/request/app-marketplace-entitlement)
- [Onside — Alternative App Marketplace](https://onside.io)
- [DMA Article 6(4) — EUR-Lex](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32022R1925)

---

## License

MIT — see [LICENSE](LICENSE) for details.

Feel free to use this as a starting point for your own marketplace. If you build something, a mention or a star is always appreciated.

---
---

# AlternativeStore — Демо-проект MarketplaceKit

> **Доклад:** «Как легально опубликоваться вне App Store» · [Mobius 2026](https://mobiusconf.com)  
> **Автор:** Сергей Вихляев · Lead iOS Developer в [Onside](https://onside.io)

Минималистичное iOS-приложение с production-структурой, демонстрирующее все слои **Alternative App Marketplace** на базе `MarketplaceKit` от Apple.

Работает полностью на моковых данных — никаких ключей Apple, никакого сервера, никакой конфигурации.  
Подставьте свои credentials и реальный бэкенд → получите живой маркетплейс.

---

## Что вы увидите

Приложение поставляется с **6 вымышленными приложениями** и двумя вариантами кнопки установки на экране детали:

| Кнопка | Поведение |
|--------|-----------|
| **Кастомная кнопка** (overlay pattern) | Ваш дизайн; прозрачный `ActionButton` перехватывает тап |
| **Стандартный `ActionButton`** | Системная кнопка Apple без кастомных стилей |

На **Симуляторе** нажатие любой кнопки запускает пошаговую анимированную визуализацию реального флоу `confirmInstall`. Каждый шаг пишется **одновременно в список на экране и в Xcode Debug Console** через `os.Logger`.

---

## Как работает флоу установки

```
Пользователь нажимает ActionButton
        ↓
MarketplaceKit показывает системный лист подтверждения
        ↓
Система вызывает closure confirmInstall { }
        ↓
Ваша бизнес-логика (auth, eligibility, …)
        ↓
GET /versions/{appleVersionId}/install  →  install_verification_token (JWT)
        ↓
return .confirmed(installVerificationToken:)
        ↓
MarketplaceKit скачивает и устанавливает .adp-пакет
```

JWT подписывается **вашим бэкендом** приватным ключом, зарегистрированным в App Store Connect.  
MarketplaceKit верифицирует подпись криптографически — это механизм защиты от пиратства Apple.

---

## Быстрый старт

```bash
open AlternativeStore_MobiusDEMO.xcodeproj
```

1. Выберите любой **iPhone Simulator** и нажмите **Cmd+R**
2. Тапните на любое приложение в списке
3. Нажмите **Install** → наблюдайте за флоу на экране и в консоли

Требования: **Xcode 26+** · **iOS 26 SDK** · **Swift 6**

---

## Структура проекта

```
AlternativeStore_MobiusDEMO/
├── Configuration/
│   └── MarketplaceConfiguration.swift      ← Единый источник истины: URL, ключи, mock-флаг
│
├── Models/
│   ├── AppModel.swift                       ← DTO каталога (отражает типичный ответ бэкенда)
│   └── AppInstallMetadata.swift             ← { install_verification_token } — модель ответа
│
├── Services/
│   ├── Protocols/
│   │   ├── CatalogProvider.swift            ← fetchApps() — mock или network
│   │   ├── InstallationConfigurationProvider.swift
│   │   └── AppLibraryProvider.swift         ← installState / statePublisher
│   │
│   ├── Mock/
│   │   └── MockCatalogProvider.swift        ← 6 захардкоженных приложений, без сети
│   │
│   ├── InstallationSupportService.swift     ← Строит InstallConfiguration + confirmInstall
│   ├── AppLibraryService.swift              ← Обёртка AppLibrary.current + заглушки симулятора
│   └── NetworkService.swift                 ← URLSession-клиент: каталог + install token
│
├── Utilities/
│   └── AppLogger.swift                      ← Каналы os.Logger (install / network / library)
│
├── ViewModels/
│   ├── FeedViewModel.swift                  ← Стейт-машина загрузки каталога
│   └── AppDetailViewModel.swift             ← Состояние установки + simulateInstall()
│
├── Views/
│   ├── Feed/
│   │   ├── FeedViewController.swift         ← Экран 1: список приложений
│   │   └── AppCell.swift
│   └── Detail/
│       ├── AppDetailViewController.swift    ← Экран 2: детали + обе кнопки установки
│       └── CustomInstallButton.swift        ← Прозрачный overlay ActionButton
│
├── Extension/
│   ├── MarketplaceExtensionExample.swift    ← Референсная реализация (не компилируется)
│   └── WellKnownMarketplaceKit.json         ← Пример конфига /.well-known/marketplace-kit
│
└── Entitlements/
    └── AlternativeStore_MobiusDEMO.entitlements
```

---

## Debug Console

Приложение использует `os.Logger` с subsystem **`io.demo.alternativestore`**.

### Xcode Debug Console

Фильтр в строке внизу консоли Xcode:
```
subsystem:io.demo.alternativestore
```

### macOS Console.app

```
subsystem:io.demo.alternativestore
```

### Категории логов

| Категория | Что отслеживает |
|-----------|-----------------|
| `install` | makeInstallConfiguration, шаги confirmInstall, обмен токенами |
| `network` | Загрузка каталога, запросы и ответы install token |
| `library` | Переходы состояний AppLibrary: available → installing → installed |

### Пример вывода (симуляция установки)

```
[install] ─────── Install Simulation START: Pixel Camera Pro ───────
[install] [1] User tapped Install
[install] [2] confirmInstall() called by MarketplaceKit
[install] [3] Fetching install_verification_token...
[install] [network] fetchInstallToken(appleVersionId: 200001) → mock
[install] [network] fetchInstallToken ← mock token (length: 38)
[install] [4] Token received → .confirmed
[install] [5] Installing...
[install] [6] Install complete ✓
[install] ─────── Install Simulation DONE: Pixel Camera Pro ────────
```

---

## Подключение к реальному бэкенду

Отредактируйте `Configuration/MarketplaceConfiguration.swift`:

```swift
enum MarketplaceConfiguration {
    static let baseURL     = URL(string: "https://api.yourstore.com")!
    static let accessToken: String? = "your-auth-token"   // заголовок x-access-token
    static let marketplaceID: Int  = 123_456_789           // из App Store Connect
    static let useMockData = false                          // ← переключите это
}
```

Ваш бэкенд должен реализовать два эндпоинта:

| Метод | Путь | Возвращает |
|-------|------|------------|
| `GET` | `/api/v1/apps` | `[AppModel]` — каталог приложений |
| `GET` | `/api/v1/versions/{appleVersionId}/install` | `{ "install_verification_token": "eyJ…" }` |

`install_verification_token` — **JWT, подписанный вашим приватным ключом**, зарегистрированным в App Store Connect под вашим маркетплейсом. MarketplaceKit верифицирует подпись — никогда не выставляйте приватный ключ в клиент.

---

## Необходимые Entitlements

Для production-маркетплейса нужны три entitlement:

| Entitlement | Назначение |
|-------------|------------|
| `com.apple.developer.marketplace.app-installation` | Обязателен для вызова `AppLibrary.install()` — ключевой entitlement |
| `com.apple.developer.in-app-payments` | Приём оплаты за приложения внутри маркетплейса |
| `com.apple.developer.associated-domains` | Universal Links — кнопки установки с вашего сайта |

Запрос entitlement маркетплейса:  
→ https://developer.apple.com/contact/request/app-marketplace-entitlement

---

## `.well-known/marketplace-kit`

Apple запрашивает `https://yourdomain.com/.well-known/marketplace-kit` для обнаружения эндпоинтов вашего бэкенда. Ключевые поля:

| Поле | Назначение |
|------|------------|
| `restore` | Вызывается для восстановления ранее купленных/установленных приложений |
| `updates.url` | Apple опрашивает этот URL для проверки обновлений |
| `updates.pollingInterval` | Интервал в секундах (43200 = 12 ч) |
| `license.*` | Управление DRM-лицензиями (выдача, продление, сертификаты) |
| `overridesByAppleItemID` | Отдельная конфигурация для самого приложения маркетплейса |

Полный формат — в `Extension/WellKnownMarketplaceKit.json`.

---

## Добавление таргета MarketplaceExtension

`MarketplaceExtension` работает в фоне для **автоматического обновления приложений** — без участия пользователя.

1. **Xcode → File → New → Target → ExtensionKit Extension**
2. В `Info.plist` расширения:
   ```xml
   <key>EXExtensionPointIdentifier</key>
   <string>com.apple.marketplace.extension</string>
   ```
3. Перенесите `Extension/MarketplaceExtensionExample.swift` в новый таргет
4. Уберите guards `#if false` / `#endif`
5. Расшарьте `NetworkService`, `AppModel` и `AppInstallMetadata` между таргетами

Расширение реализует четыре метода:

| Метод | Назначение |
|-------|------------|
| `additionalHeaders(for:account:)` | Auth-заголовки для запросов Apple → ваш бэкенд |
| `requestFailed(with:)` | Обработка 401; вернуть `true` для повтора после обновления токена |
| `availableAppVersions(forAppleItemIDs:)` | Сообщить Apple, какие версии доступны для данных приложений |
| `automaticUpdates(for:)` | Предоставить объекты `AutomaticUpdate` для установленных приложений с обновлениями |

---

## Что не будет работать без ключей Apple

| Функция | Почему не работает |
|---------|--------------------|
| Тап на `ActionButton` | Требует provisioning profile с entitlement маркетплейса |
| `AppLibrary.current` | Возвращает пустые данные без зарегистрированного marketplace ID |
| Завершение `confirmInstall` | `install_verification_token` должен быть валидным JWT от вашего зарегистрированного бэкенда |
| Вызов `MarketplaceExtension` | Система вызывает расширения только от зарегистрированных маркетплейсов |

**Режим симулятора** (`useMockData = true`) обходит всё это с реалистичными заглушками и пошаговой анимацией.

---

## Доступность

| Регион | Доступно с |
|--------|------------|
| Европейский Союз | iOS 17.4 · Март 2024 (DMA Статья 6(4)) |
| Япония | iOS 17.4 · Январь 2026 (MSCA) |

---

## Ссылки

- [Apple: Distributing apps in alternative marketplaces](https://developer.apple.com/documentation/appdistribution)
- [Apple: MarketplaceKit documentation](https://developer.apple.com/documentation/marketplacekit)
- [Apple: Notarization for alternative marketplaces](https://developer.apple.com/documentation/appdistribution/notarization-for-apps-distributed-with-alternative-marketplace)
- [Apple: Request marketplace entitlement](https://developer.apple.com/contact/request/app-marketplace-entitlement)
- [Onside — Alternative App Marketplace](https://onside.io)
- [DMA Article 6(4) — EUR-Lex](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32022R1925)

---

## Лицензия

MIT — подробности в [LICENSE](LICENSE).

Используйте как отправную точку для своего маркетплейса. Если что-то построите — упоминание или звезда всегда приятны.
