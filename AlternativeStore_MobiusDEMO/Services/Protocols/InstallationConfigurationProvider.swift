import Foundation
import MarketplaceKit
import _MarketplaceKit_UIKit

/// Builds `InstallConfiguration` objects that MarketplaceKit needs to perform installs.
/// Собирает объекты `InstallConfiguration`, необходимые MarketplaceKit для установки приложений.
///
/// The key flow / Ключевой поток:
/// 1. UI calls `makeInstallConfiguration(for:accountId:)`.
///    UI вызывает `makeInstallConfiguration(for:accountId:)`.
/// 2. The returned `InstallConfiguration` contains a `confirmInstall` closure.
///    Возвращённый `InstallConfiguration` содержит замыкание `confirmInstall`.
/// 3. When the user taps the system install button, MarketplaceKit calls `confirmInstall`.
///    При нажатии системной кнопки установки MarketplaceKit вызывает `confirmInstall`.
/// 4. Inside `confirmInstall`, we hit the backend for an `install_verification_token`.
///    Внутри `confirmInstall` запрашиваем `install_verification_token` у бэкенда.
/// 5. We return `.confirmed(installVerificationToken:)` — MarketplaceKit proceeds with install.
///    Возвращаем `.confirmed(installVerificationToken:)` — MarketplaceKit выполняет установку.
///
/// See Apple's MarketplaceKit documentation for advanced patterns.
/// Подробнее — в документации Apple по MarketplaceKit.
protocol InstallationConfigurationProvider: Sendable {

    /// Creates an `InstallConfiguration` for a fresh install.
    /// Создаёт `InstallConfiguration` для первичной установки.
    func makeInstallConfiguration(
        for app: AppModel,
        accountId: String
    ) -> InstallConfiguration

    /// Creates an `InstallConfiguration` for an update.
    /// Создаёт `InstallConfiguration` для обновления приложения.
    func makeUpdateConfiguration(
        for app: AppModel,
        accountId: String
    ) -> InstallConfiguration

    /// Fetches the install verification token from the backend.
    /// Получает токен верификации установки с бэкенда.
    func fetchInstallToken(appleVersionId: Int) async throws -> String
}
