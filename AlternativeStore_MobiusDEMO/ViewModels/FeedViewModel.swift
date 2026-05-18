import Foundation
import Combine

/// Drives the feed screen — loads catalog and exposes per-app install states.
/// Управляет экраном ленты: загружает каталог и предоставляет состояния установки для каждого приложения.
final class FeedViewModel {

    enum State {
        case loading
        case loaded([AppModel])
        case error(String)
    }

    @Published private(set) var state: State = .loading

    private let catalogProvider: any CatalogProvider
    private let appLibraryProvider: AppLibraryServiceImpl

    init(
        catalogProvider: any CatalogProvider,
        appLibraryProvider: AppLibraryServiceImpl
    ) {
        self.catalogProvider = catalogProvider
        self.appLibraryProvider = appLibraryProvider
    }

    func loadApps() {
        state = .loading
        Task {
            do {
                let apps = try await catalogProvider.fetchApps()
                self.state = .loaded(apps)
            } catch {
                self.state = .error(error.localizedDescription)
            }
        }
    }

    func installState(for app: AppModel) -> AppInstallState {
        appLibraryProvider.installState(forAppleItemId: app.appleItemId)
    }
}
