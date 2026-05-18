import Foundation
import Combine
import MarketplaceKit
import Observation

/// Wraps `AppLibrary.current` and exposes per-app installation state.
/// Оборачивает `AppLibrary.current` и предоставляет состояние установки для каждого приложения.
///
/// On simulator, AppLibrary is non-functional — we return `.available` for everything
/// so the UI can still render.
///
/// На симуляторе AppLibrary не работает — возвращаем `.available` для всех приложений,
/// чтобы интерфейс мог отображаться.
@Observable
final class AppLibraryServiceImpl: AppLibraryService, @unchecked Sendable {

    // MARK: - Public

    private(set) var isReady = false

    func installState(forAppleItemId id: Int) -> AppInstallState {
        #if targetEnvironment(simulator)
        return simulatorStates[id] ?? .available
        #else
        let app = AppLibrary.current.app(forAppleItemID: id)
        return mapAppState(app)
        #endif
    }

    func statePublisher(forAppleItemId id: Int) -> AnyPublisher<AppInstallState, Never> {
        #if targetEnvironment(simulator)
        return simulatorStateSubjects
            .value[id, default: CurrentValueSubject(.available)]
            .eraseToAnyPublisher()
        #else
        return Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .map { [weak self] _ in
                self?.installState(forAppleItemId: id) ?? .available
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
        #endif
    }

    // MARK: - Initialization

    init() {
        #if targetEnvironment(simulator)
        isReady = true
        #else
        waitForAppLibrary()
        #endif
    }

    // MARK: - Simulator Mock State (for demo)
    // MARK: - Симулируемые состояния (для демо на симуляторе)

    #if targetEnvironment(simulator)
    /// Allows the demo UI to simulate state transitions on the simulator.
    /// Позволяет демо-интерфейсу симулировать переходы состояний на симуляторе.
    func setSimulatorState(_ state: AppInstallState, forAppleItemId id: Int) {
        simulatorStates[id] = state
        if simulatorStateSubjects.value[id] == nil {
            simulatorStateSubjects.value[id] = CurrentValueSubject(state)
        } else {
            simulatorStateSubjects.value[id]?.send(state)
        }
    }

    private var simulatorStates: [Int: AppInstallState] = [:]
    private var simulatorStateSubjects = CurrentValueSubject<
        [Int: CurrentValueSubject<AppInstallState, Never>], Never
    >([:])
    #endif

    // MARK: - Private

    #if !targetEnvironment(simulator)
    private func waitForAppLibrary() {
        let library = AppLibrary.current
        if library.isLoading {
            withObservationTracking {
                _ = library.isLoading
            } onChange: { [weak self] in
                DispatchQueue.main.async {
                    self?.waitForAppLibrary()
                }
            }
        } else {
            isReady = true
        }
    }

    private func mapAppState(_ app: AppLibrary.App) -> AppInstallState {
        switch app.state {
        case .available:
            return .available
        case .installing(let installation):
            return .installing(progress: installation.progress?.fractionCompleted)
        case .updating(let installation):
            return .installing(progress: installation.progress?.fractionCompleted)
        case .installed:
            return .installed
        @unknown default:
            return .available
        }
    }
    #endif
}
