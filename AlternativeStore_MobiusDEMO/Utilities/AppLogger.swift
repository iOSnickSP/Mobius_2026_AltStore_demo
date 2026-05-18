import os

/// Centralised logging for the AlternativeStore demo app.
/// Централизованное логирование демо-приложения.
///
/// All messages are routed through `os.Logger`, which means they appear in:
///   - Xcode Debug Console (Cmd+Shift+C)
///   - macOS Console.app (filter by subsystem below)
///
/// Все сообщения проходят через `os.Logger` и отображаются в:
///   - Xcode Debug Console (Cmd+Shift+C)
///   - macOS Console.app (фильтр по subsystem)
///
/// ## Filtering in Xcode Console
/// Type into the filter bar:
/// ```
/// subsystem:io.demo.alternativestore
/// ```
///
/// ## Filtering in Console.app
/// ```
/// subsystem:io.demo.alternativestore
/// ```
///
/// ## Categories
/// | Category  | What it tracks                                          |
/// |-----------|---------------------------------------------------------|
/// | install   | InstallConfiguration, confirmInstall, token exchange    |
/// | network   | Catalog fetch, install token requests/responses         |
/// | library   | AppLibrary state transitions (available/installing/…)   |
enum AppLogger {

    private static let subsystem = "io.demo.alternativestore"

    /// Install flow: makeInstallConfiguration, confirmInstall, token exchange.
    /// Поток установки: makeInstallConfiguration, confirmInstall, обмен токеном.
    static let install = Logger(subsystem: subsystem, category: "install")

    /// Network layer: catalog fetch, install token requests.
    /// Сетевой слой: загрузка каталога, запросы токена установки.
    static let network = Logger(subsystem: subsystem, category: "network")

    /// AppLibrary state: available → installing → installed.
    /// Состояния AppLibrary: available → installing → installed.
    static let library = Logger(subsystem: subsystem, category: "library")
}
