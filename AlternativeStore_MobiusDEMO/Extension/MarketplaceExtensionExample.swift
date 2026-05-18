// ──────────────────────────────────────────────────────────────────────
// REFERENCE IMPLEMENTATION — MarketplaceExtension (ExtensionKit target)
// СПРАВОЧНАЯ РЕАЛИЗАЦИЯ — MarketplaceExtension (таргет ExtensionKit)
// ──────────────────────────────────────────────────────────────────────
//
// This file is NOT compiled as part of the main app target.
// Этот файл НЕ компилируется в составе основного таргета приложения.
// It's a reference for creating the MarketplaceExtension ExtensionKit target.
// Он служит справочником для создания таргета MarketplaceExtension на ExtensionKit.
//
// To use it in a real project / Чтобы использовать в реальном проекте:
// 1. In Xcode → File → New → Target → ExtensionKit Extension
// 2. Set EXExtensionPointIdentifier to "com.apple.marketplace.extension" in Info.plist
//    Установите EXExtensionPointIdentifier = "com.apple.marketplace.extension" в Info.plist
// 3. Move this file into the new extension target
//    Перенесите этот файл в новый таргет расширения
// 4. Share the NetworkService and models with the extension target
//    Разделите NetworkService и модели с таргетом расширения
//
// The MarketplaceExtension protocol has 4 required methods:
// Протокол MarketplaceExtension требует 4 метода:
//   - additionalHeaders(for:account:) → auth headers for Apple's requests to your backend
//                                       заголовки авторизации для запросов Apple к вашему бэкенду
//   - requestFailed(with:)           → handle 401s, return true to retry
//                                       обработка 401, вернуть true для повтора
//   - availableAppVersions(forAppleItemIDs:) → tell Apple which versions are available
//                                              сообщить Apple о доступных версиях
//   - automaticUpdates(for:)         → provide updates for installed apps
//                                      предоставить обновления для установленных приложений
//
// See Apple's MarketplaceKit documentation for advanced patterns.
// Подробные паттерны — в документации Apple по MarketplaceKit.
// ──────────────────────────────────────────────────────────────────────

#if false // Disabled — move to a dedicated ExtensionKit target to enable

import Foundation
import ExtensionFoundation
import MarketplaceKit

@main
final class DemoMarketplaceExtension: MarketplaceExtension, @unchecked Sendable {

    private let networkService = NetworkService()

    required init() {}

    // MARK: - Auth Headers / Заголовки авторизации

    /// Called by Apple when making requests to your backend URLs
    /// (from `/.well-known/marketplace-kit` configuration).
    /// You must return auth headers so your backend can authenticate the request.
    ///
    /// Вызывается Apple при запросах к вашим URL бэкенда
    /// (из конфигурации `/.well-known/marketplace-kit`).
    /// Необходимо вернуть заголовки авторизации для аутентификации запроса.
    func additionalHeaders(for request: URLRequest, account: String) -> [String: String]? {
        var headers: [String: String] = [:]
        if let token = MarketplaceConfiguration.accessToken {
            headers["x-access-token"] = token
        }
        return headers.isEmpty ? nil : headers
    }

    // MARK: - Error Handling / Обработка ошибок

    /// Called when a request to your backend fails.
    /// Return `true` to retry the request (e.g. after refreshing an auth token).
    ///
    /// Вызывается при неудачном запросе к бэкенду.
    /// Верните `true` для повторного запроса (например, после обновления токена).
    func requestFailed(with response: HTTPURLResponse) -> Bool {
        switch response.statusCode {
        case 401:
            // In production: refresh the token here, then return true
            return false
        default:
            return false
        }
    }

    // MARK: - Available Versions / Доступные версии

    /// Called by AppLibrary to check which versions are available for given Apple Item IDs.
    /// Return `AppVersion` objects for apps that have updates ready.
    ///
    /// Вызывается AppLibrary для проверки доступных версий по Apple Item ID.
    /// Вернуть `AppVersion` для приложений с готовыми обновлениями.
    func availableAppVersions(forAppleItemIDs ids: [AppleItemID]) -> [AppVersion]? {
        // In production: check your local cache of available updates
        // and return AppVersion for each app that has a newer version.
        return nil
    }

    // MARK: - Automatic Updates / Автоматические обновления

    /// Called by the system to perform background automatic updates.
    /// For each installed app that has an update, return an `AutomaticUpdate`
    /// with the new ADP URL and a fresh install verification token.
    ///
    /// Вызывается системой для фоновых автоматических обновлений.
    /// Для каждого установленного приложения с обновлением вернуть `AutomaticUpdate`
    /// с новым ADP URL и свежим токеном верификации установки.
    func automaticUpdates(for installedAppVersions: [AppVersion]) async throws -> [AutomaticUpdate] {
        var updates: [AutomaticUpdate] = []

        for installedVersion in installedAppVersions {
            // 1. Check if an update is available for this app
            // 2. If yes, fetch a fresh install verification token
            // 3. Build an AutomaticUpdate

            // Example (pseudo-code for production):
            //
            // guard let update = availableUpdates[installedVersion.appleItemID] else { continue }
            // let token = try await networkService.fetchInstallToken(appleVersionId: update.appleVersionId)
            // updates.append(AutomaticUpdate(
            //     appleItemID: installedVersion.appleItemID,
            //     alternativeDistributionPackage: update.adpURL,
            //     account: "user-account-id",
            //     installVerificationToken: token.installVerificationToken
            // ))

            _ = installedVersion // Suppress unused warning
        }

        return updates
    }
}

#endif
