import Foundation
import os
import MarketplaceKit
import _MarketplaceKit_UIKit

/// Builds `InstallConfiguration` objects for MarketplaceKit.
/// Собирает объекты `InstallConfiguration` для MarketplaceKit.
///
/// Simplified implementation of an InstallConfiguration builder.
/// The critical piece is the `confirmInstall` closure — it's called by MarketplaceKit
/// when the user confirms the install via the system button.
///
/// Упрощённая реализация сборщика InstallConfiguration.
/// Ключевой элемент — замыкание `confirmInstall`: его вызывает MarketplaceKit,
/// когда пользователь подтверждает установку через системную кнопку.
///
/// Flow / Поток:
/// ```
///  User taps ActionButton / Пользователь нажимает ActionButton
///       ↓
///  MarketplaceKit shows system confirmation / MarketplaceKit показывает системное подтверждение
///       ↓
///  System calls `confirmInstall` closure / Система вызывает замыкание `confirmInstall`
///       ↓
///  We fetch `install_verification_token` from backend / Запрашиваем токен у бэкенда
///       ↓
///  Return `.confirmed(installVerificationToken:)` → install proceeds / Установка идёт дальше
/// ```
final class InstallationSupportService: InstallationConfigurationProvider, @unchecked Sendable {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    // MARK: - InstallationConfigurationProvider

    func makeInstallConfiguration(
        for app: AppModel,
        accountId: String
    ) -> InstallConfiguration {
        guard let adpURL = app.alternativeDistributionPackageURL else {
            fatalError("Cannot create install configuration without alternativeDistributionPackageURL")
        }

        AppLogger.install.debug("makeInstallConfiguration — app: \(app.name, privacy: .public), account: \(accountId, privacy: .public)")

        return InstallConfiguration(
            install: .init(
                account: accountId,
                appleItemID: AppleItemID(app.appleItemId),
                alternativeDistributionPackage: adpURL,
                isUpdate: false
            ),
            confirmInstall: { [weak self] in
                guard let self else { return .cancel }
                return await self.performConfirmInstall(appleVersionId: app.appleVersionId)
            }
        )
    }

    func makeUpdateConfiguration(
        for app: AppModel,
        accountId: String
    ) -> InstallConfiguration {
        guard let adpURL = app.alternativeDistributionPackageURL else {
            fatalError("Cannot create update configuration without alternativeDistributionPackageURL")
        }

        AppLogger.install.debug("makeUpdateConfiguration — app: \(app.name, privacy: .public), account: \(accountId, privacy: .public)")

        return InstallConfiguration(
            install: .init(
                account: accountId,
                appleItemID: AppleItemID(app.appleItemId),
                alternativeDistributionPackage: adpURL,
                isUpdate: true
            ),
            confirmInstall: { [weak self] in
                guard let self else { return .cancel }
                return await self.performConfirmInstall(appleVersionId: app.appleVersionId)
            }
        )
    }

    func fetchInstallToken(appleVersionId: Int) async throws -> String {
        let metadata = try await networkService.fetchInstallToken(appleVersionId: appleVersionId)
        return metadata.installVerificationToken
    }

    // MARK: - Private

    /// Called by MarketplaceKit inside the system install confirmation sheet.
    /// Must return a valid `InstallConfirmationResult` to proceed.
    ///
    /// Вызывается MarketplaceKit внутри системного листа подтверждения установки.
    /// Должен вернуть валидный `InstallConfirmationResult` для продолжения.
    private func performConfirmInstall(appleVersionId: Int) async -> InstallConfirmationResult {
        AppLogger.install.debug("confirmInstall → fetching token for appleVersionId: \(appleVersionId)")

        do {
            let token = try await networkService.fetchInstallToken(appleVersionId: appleVersionId)
            AppLogger.install.debug("confirmInstall ← token received (length: \(token.installVerificationToken.count)) → .confirmed")
            return .confirmed(
                installVerificationToken: token.installVerificationToken,
                authenticationContext: nil
            )
        } catch {
            AppLogger.install.error("confirmInstall ← FAILED: \(error.localizedDescription, privacy: .public) → .cancel")
            assertionFailure("confirmInstall failed: \(error)")
            return .cancel
        }
    }
}
