import Foundation

/// Provides the list of apps available in the marketplace.
///
/// Two implementations:
/// - `MockCatalogProvider`  — hardcoded demo data, no network
/// - `NetworkCatalogProvider` — fetches from your backend via `NetworkService`
protocol CatalogProvider: Sendable {
    func fetchApps() async throws -> [AppModel]
}
