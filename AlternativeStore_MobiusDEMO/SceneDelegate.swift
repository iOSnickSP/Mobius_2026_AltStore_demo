import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let networkService = NetworkService()
        let appLibraryProvider = AppLibraryServiceImpl()
        let installationService = InstallationSupportService(networkService: networkService)
        let catalogProvider: any CatalogProvider = MarketplaceConfiguration.useMockData
            ? MockCatalogProvider()
            : NetworkCatalogProvider(networkService: networkService)

        let feedVM = FeedViewModel(
            catalogProvider: catalogProvider,
            appLibraryProvider: appLibraryProvider
        )
        let feedVC = FeedViewController(
            viewModel: feedVM,
            appLibraryProvider: appLibraryProvider,
            installationService: installationService,
            networkService: networkService
        )
        let nav = UINavigationController(rootViewController: feedVC)
        nav.navigationBar.prefersLargeTitles = true

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = nav
        self.window = window
        window.makeKeyAndVisible()
    }
}

/// Fetches the app catalog from the real backend.
struct NetworkCatalogProvider: CatalogProvider {
    let networkService: NetworkService

    func fetchApps() async throws -> [AppModel] {
        try await networkService.fetchCatalog()
    }
}
