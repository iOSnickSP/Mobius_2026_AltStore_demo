import Foundation
import os

/// Minimal HTTP client for the marketplace backend.
/// Минимальный HTTP-клиент для бэкенда маркетплейса.
///
/// Handles two operations:
/// Реализует две операции:
/// 1. Fetching the app catalog (`GET /api/v1/apps`)
///    Загрузка каталога приложений (`GET /api/v1/apps`)
/// 2. Fetching the install verification token (`GET /api/v1/versions/{id}/install`)
///    Получение токена верификации установки (`GET /api/v1/versions/{id}/install`)
///
/// When `MarketplaceConfiguration.useMockData` is `true`, network calls
/// return mock data without hitting the network.
///
/// При `MarketplaceConfiguration.useMockData == true` сетевые вызовы
/// возвращают мок-данные без обращения к сети.
final class NetworkService: @unchecked Sendable {

    private let session: URLSession
    private let decoder: JSONDecoder

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    // MARK: - Catalog

    /// Fetches the full app catalog from the backend.
    /// When mock mode is on, returns `MockCatalogProvider.mockApps`.
    ///
    /// Загружает полный каталог приложений с бэкенда.
    /// В режиме мока возвращает `MockCatalogProvider.mockApps`.
    func fetchCatalog() async throws -> [AppModel] {
        if MarketplaceConfiguration.useMockData {
            let apps = MockCatalogProvider.mockApps
            AppLogger.network.debug("fetchCatalog() ← mock: \(apps.count) apps")
            return apps
        }

        let url = MarketplaceConfiguration.baseURL
            .appendingPathComponent(MarketplaceConfiguration.catalogPath)

        AppLogger.network.debug("fetchCatalog() → GET \(url.absoluteString, privacy: .public)")

        var request = URLRequest(url: url)
        applyHeaders(to: &request)

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)

        let apps = try decoder.decode([AppModel].self, from: data)
        AppLogger.network.debug("fetchCatalog() ← \(apps.count) apps")
        return apps
    }

    // MARK: - Install Token

    /// Fetches the install verification token for a specific app version.
    ///
    /// The backend signs a JWT with the private key registered in App Store Connect.
    /// MarketplaceKit uses this token to verify that the install request is legitimate.
    ///
    /// When mock mode is on, returns a placeholder token.
    ///
    /// Получает токен верификации установки для конкретной версии приложения.
    /// Бэкенд подписывает JWT приватным ключом, зарегистрированным в App Store Connect.
    /// MarketplaceKit использует этот токен для проверки легитимности установки.
    /// В режиме мока возвращает заглушку токена.
    func fetchInstallToken(appleVersionId: Int) async throws -> AppInstallMetadata {
        if MarketplaceConfiguration.useMockData {
            AppLogger.network.debug("fetchInstallToken(appleVersionId: \(appleVersionId)) → mock")
            try await Task.sleep(for: .milliseconds(300))
            let metadata = AppInstallMetadata(
                installVerificationToken: "mock-jwt-token-for-demo-\(appleVersionId)"
            )
            AppLogger.network.debug("fetchInstallToken ← mock token (length: \(metadata.installVerificationToken.count))")
            return metadata
        }

        let path = String(
            format: MarketplaceConfiguration.installTokenPathTemplate,
            appleVersionId
        )
        let url = MarketplaceConfiguration.baseURL.appendingPathComponent(path)

        AppLogger.network.debug("fetchInstallToken(appleVersionId: \(appleVersionId)) → GET \(url.absoluteString, privacy: .public)")

        var request = URLRequest(url: url)
        applyHeaders(to: &request)

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)

        let metadata = try decoder.decode(AppInstallMetadata.self, from: data)
        AppLogger.network.debug("fetchInstallToken ← token received (length: \(metadata.installVerificationToken.count))")
        return metadata
    }

    // MARK: - Private

    private func applyHeaders(to request: inout URLRequest) {
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = MarketplaceConfiguration.accessToken {
            request.setValue(token, forHTTPHeaderField: "x-access-token")
        }
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            AppLogger.network.error("validateResponse: not an HTTPURLResponse")
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            AppLogger.network.error("validateResponse: HTTP \(http.statusCode)")
            throw NetworkError.httpError(statusCode: http.statusCode)
        }
        AppLogger.network.debug("validateResponse: HTTP \(http.statusCode)")
    }
}

enum NetworkError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error \(code)"
        }
    }
}
