import Foundation
import Combine
import MarketplaceKit

/// Represents the installation state of a single app from AppLibrary's perspective.
enum AppInstallState: Equatable, Sendable {
    case available
    case installing(progress: Double?)
    case installed
}

/// Wraps `AppLibrary.current` to expose per-app installation state
/// in a Combine-friendly way.
/// Оборачивает `AppLibrary.current` для Combine-совместимого доступа к состоянию установки.
///
/// On the simulator, `AppLibrary` is unavailable — the implementation
/// returns mock states so the demo UI still works.
/// На симуляторе `AppLibrary` недоступен — реализация возвращает мок-состояния,
/// чтобы демо-интерфейс мог отображаться.
///
/// See Apple's MarketplaceKit documentation for details on AppLibrary.
/// Подробнее об AppLibrary — в документации Apple по MarketplaceKit.
protocol AppLibraryService: Observable, AnyObject, Sendable {

    /// Whether the AppLibrary has finished initial loading.
    var isReady: Bool { get }

    /// Returns the current installation state for a given Apple Item ID.
    func installState(forAppleItemId id: Int) -> AppInstallState

    /// Observe state changes for a specific app.
    func statePublisher(forAppleItemId id: Int) -> AnyPublisher<AppInstallState, Never>
}
