import Foundation

/// Single source of truth for all marketplace configuration.
/// Единственный источник истины для всей конфигурации маркетплейса.
///
/// To connect to a real backend and enable actual installs:
/// Чтобы подключить реальный бэкенд и включить установку приложений:
/// 1. Set `baseURL` to your backend root (e.g. `https://api.yourstore.com`)
///    Установите `baseURL` на корень вашего бэкенда.
/// 2. Set `marketplaceID` to the value from App Store Connect
///    Установите `marketplaceID` из App Store Connect.
/// 3. Set `useMockData` to `false`
///    Переключите `useMockData` в `false`.
/// 4. Ensure your provisioning profile includes `com.apple.developer.marketplace.app-installation`
///    Убедитесь, что provisioning profile содержит `com.apple.developer.marketplace.app-installation`.
enum MarketplaceConfiguration: Sendable {

    // MARK: - Backend

    static let baseURL = URL(string: "https://your-backend.example.com")!

    /// Auth token sent as `x-access-token` header in every API request.
    /// Токен авторизации, передаваемый в заголовке `x-access-token` каждого запроса.
    static let accessToken: String? = nil

    // MARK: - Apple Marketplace

    /// Your marketplace Apple Item ID from App Store Connect.
    /// Apple Item ID вашего маркетплейса из App Store Connect.
    static let marketplaceID: Int = 0

    // MARK: - Behaviour

    /// When `true`, the app uses hardcoded mock data instead of hitting the network.
    /// Flip to `false` once you have a backend running.
    ///
    /// При значении `true` приложение использует мок-данные без обращений к сети.
    /// Переключите в `false` когда бэкенд готов.
    static let useMockData = true

    // MARK: - API Paths

    /// Catalog endpoint — returns the list of available apps.
    /// Эндпоинт каталога — возвращает список доступных приложений.
    static let catalogPath = "/api/v1/apps"

    /// Install token endpoint template — `%d` is replaced with `appleVersionId`.
    /// Шаблон эндпоинта для токена установки — `%d` заменяется на `appleVersionId`.
    static let installTokenPathTemplate = "/api/v1/versions/%d/install"
}
