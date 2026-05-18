import Foundation
import Combine
import os
import MarketplaceKit
import _MarketplaceKit_UIKit

/// Drives the app detail screen — manages install state and builds configurations.
/// Управляет экраном деталей приложения: следит за состоянием установки и собирает конфигурации.
final class AppDetailViewModel {

    let app: AppModel

    @Published private(set) var installState: AppInstallState = .available
    @Published private(set) var installLog: [String] = []

    private let appLibraryProvider: AppLibraryServiceImpl
    private let installationService: InstallationSupportService
    private var cancellables = Set<AnyCancellable>()

    init(
        app: AppModel,
        appLibraryProvider: AppLibraryServiceImpl,
        installationService: InstallationSupportService
    ) {
        self.app = app
        self.appLibraryProvider = appLibraryProvider
        self.installationService = installationService

        installState = appLibraryProvider.installState(forAppleItemId: app.appleItemId)

        appLibraryProvider.statePublisher(forAppleItemId: app.appleItemId)
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self else { return }
                self.installState = state
                AppLogger.library.debug("\(self.app.name, privacy: .public): state → \(String(describing: state), privacy: .public)")
            }
            .store(in: &cancellables)
    }

    // MARK: - Public

    /// Builds an `InstallConfiguration` for the standard MarketplaceKit.ActionButton.
    /// Собирает `InstallConfiguration` для стандартного MarketplaceKit.ActionButton.
    func makeInstallConfiguration() -> InstallConfiguration? {
        guard app.alternativeDistributionPackageURL != nil else { return nil }
        return installationService.makeInstallConfiguration(for: app, accountId: "demo-user")
    }

    /// Simulates the full install flow on the Simulator.
    ///
    /// Each step is written to both the on-screen log and the Xcode Debug Console
    /// via `os.Logger` (category: "install", subsystem: "io.demo.alternativestore").
    ///
    /// Симулирует полный поток установки на симуляторе.
    /// Каждый шаг выводится одновременно в UI-лог и в Xcode Debug Console
    /// через `os.Logger` (category: "install", subsystem: "io.demo.alternativestore").
    func simulateInstall() {
        guard installState != .installed else {
            AppLogger.install.debug("simulateInstall() skipped — \(self.app.name, privacy: .public) already installed")
            return
        }
        installLog = []

        AppLogger.install.debug("─────── Install Simulation START: \(self.app.name, privacy: .public) ───────")

        Task {
            appendLog("User tapped Install")
            try? await Task.sleep(for: .milliseconds(500))

            appendLog("confirmInstall() called by MarketplaceKit")
            try? await Task.sleep(for: .milliseconds(500))

            appendLog("Fetching install_verification_token...")
            try? await Task.sleep(for: .milliseconds(700))

            appendLog("Token received → .confirmed")
            try? await Task.sleep(for: .milliseconds(400))

            self.installState = .installing(progress: 0)
            appendLog("Installing...")

            for i in 1...10 {
                try? await Task.sleep(for: .milliseconds(150))
                self.installState = .installing(progress: Double(i) / 10.0)
            }

            self.installState = .installed
            appendLog("Install complete ✓")

            AppLogger.install.debug("─────── Install Simulation DONE:  \(self.app.name, privacy: .public) ────────")

            #if targetEnvironment(simulator)
            appLibraryProvider.setSimulatorState(.installed, forAppleItemId: app.appleItemId)
            #endif
        }
    }

    // MARK: - Private

    private func appendLog(_ message: String) {
        let step = installLog.count + 1
        let entry = "[\(step)] \(message)"
        installLog.append(entry)
        AppLogger.install.debug("\(entry, privacy: .public)")
    }
}
