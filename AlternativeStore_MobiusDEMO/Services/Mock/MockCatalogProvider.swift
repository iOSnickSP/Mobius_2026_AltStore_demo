import Foundation

/// Provides hardcoded mock apps for demo purposes.
/// Replace with a network-backed provider when connecting to a real backend.
///
/// Предоставляет захардкоженные мок-приложения для демонстрационных целей.
/// Замените на реальный сетевой провайдер при подключении бэкенда.
struct MockCatalogProvider: CatalogProvider {

    func fetchApps() async throws -> [AppModel] {
        try await Task.sleep(for: .milliseconds(400))
        return Self.mockApps
    }

    static let mockApps: [AppModel] = [
        AppModel(
            id: 1,
            name: "Pixel Camera Pro",
            bundleId: "com.example.pixelcamera",
            developerName: "PixelWorks Inc.",
            description: "Professional camera app with RAW support, manual controls, and AI-powered scene detection. Capture stunning photos with full creative control over exposure, focus, and white balance.",
            shortVersionString: "3.2.1",
            iconURL: nil,
            screenshotURLs: [],
            price: "$4.99",
            isFree: false,
            appleItemId: 100_001,
            appleVersionId: 200_001,
            alternativeDistributionPackageURL: URL(string: "https://your-backend.example.com/packages/pixelcamera/3.2.1.adp"),
            sizeBytes: 48_000_000,
            category: "Photo & Video",
            iconColorHex: "#007AFF",
            iconEmoji: "📷",
            screenshotPlaceholders: [
                .init(colorHex: "#1a1a2e", label: "Camera UI"),
                .init(colorHex: "#16213e", label: "RAW Editor"),
                .init(colorHex: "#0f3460", label: "Filters"),
            ]
        ),
        AppModel(
            id: 2,
            name: "CodeRunner",
            bundleId: "com.example.coderunner",
            developerName: "DevTools Studio",
            description: "Run Python, JavaScript, and Swift code snippets directly on your iPhone. Includes syntax highlighting, autocomplete, and a built-in terminal emulator.",
            shortVersionString: "2.0.0",
            iconURL: nil,
            screenshotURLs: [],
            price: "Free",
            isFree: true,
            appleItemId: 100_002,
            appleVersionId: 200_002,
            alternativeDistributionPackageURL: URL(string: "https://your-backend.example.com/packages/coderunner/2.0.0.adp"),
            sizeBytes: 32_500_000,
            category: "Developer Tools",
            iconColorHex: "#34C759",
            iconEmoji: "</>",
            screenshotPlaceholders: [
                .init(colorHex: "#1b2838", label: "Code Editor"),
                .init(colorHex: "#2a3950", label: "Terminal"),
            ]
        ),
        AppModel(
            id: 3,
            name: "BeatSync",
            bundleId: "com.example.beatsync",
            developerName: "AudioLabs",
            description: "Create music with AI-assisted beat generation. Mix tracks, add effects, and export in lossless quality. Supports MIDI controllers and AirDrop sharing.",
            shortVersionString: "1.5.3",
            iconURL: nil,
            screenshotURLs: [],
            price: "$9.99",
            isFree: false,
            appleItemId: 100_003,
            appleVersionId: 200_003,
            alternativeDistributionPackageURL: URL(string: "https://your-backend.example.com/packages/beatsync/1.5.3.adp"),
            sizeBytes: 95_000_000,
            category: "Music",
            iconColorHex: "#FF9500",
            iconEmoji: "♪",
            screenshotPlaceholders: [
                .init(colorHex: "#2d1b69", label: "Beat Maker"),
                .init(colorHex: "#3a1f8e", label: "Mixer"),
                .init(colorHex: "#4a27a8", label: "Effects"),
            ]
        ),
        AppModel(
            id: 4,
            name: "VaultPass",
            bundleId: "com.example.vaultpass",
            developerName: "SecureTech",
            description: "Zero-knowledge password manager with biometric unlock, secure notes, and cross-device sync. Your data never leaves your devices unencrypted.",
            shortVersionString: "5.1.0",
            iconURL: nil,
            screenshotURLs: [],
            price: "Free",
            isFree: true,
            appleItemId: 100_004,
            appleVersionId: 200_004,
            alternativeDistributionPackageURL: URL(string: "https://your-backend.example.com/packages/vaultpass/5.1.0.adp"),
            sizeBytes: 22_000_000,
            category: "Utilities",
            iconColorHex: "#5856D6",
            iconEmoji: "🔒",
            screenshotPlaceholders: [
                .init(colorHex: "#1a1a2e", label: "Vault"),
                .init(colorHex: "#25254a", label: "Generator"),
            ]
        ),
        AppModel(
            id: 5,
            name: "FitTrack+",
            bundleId: "com.example.fittrackplus",
            developerName: "HealthFirst Co.",
            description: "Advanced fitness tracker with Apple Watch integration. Workout plans, nutrition logging, body composition analysis, and detailed progress charts.",
            shortVersionString: "4.0.2",
            iconURL: nil,
            screenshotURLs: [],
            price: "$2.99",
            isFree: false,
            appleItemId: 100_005,
            appleVersionId: 200_005,
            alternativeDistributionPackageURL: URL(string: "https://your-backend.example.com/packages/fittrack/4.0.2.adp"),
            sizeBytes: 58_000_000,
            category: "Health & Fitness",
            iconColorHex: "#FF2D55",
            iconEmoji: "♥",
            screenshotPlaceholders: [
                .init(colorHex: "#2d0a1a", label: "Dashboard"),
                .init(colorHex: "#3d1028", label: "Workouts"),
                .init(colorHex: "#4d1636", label: "Nutrition"),
            ]
        ),
        AppModel(
            id: 6,
            name: "Horizon Browser",
            bundleId: "com.example.horizon",
            developerName: "OpenWeb Foundation",
            description: "Privacy-first web browser with built-in ad blocker, tracker protection, and a VPN. Chromium-based engine with native iOS look and feel.",
            shortVersionString: "1.0.0",
            iconURL: nil,
            screenshotURLs: [],
            price: "Free",
            isFree: true,
            appleItemId: 100_006,
            appleVersionId: 200_006,
            alternativeDistributionPackageURL: URL(string: "https://your-backend.example.com/packages/horizon/1.0.0.adp"),
            sizeBytes: 110_000_000,
            category: "Productivity",
            iconColorHex: "#30B0C7",
            iconEmoji: "🌐",
            screenshotPlaceholders: [
                .init(colorHex: "#0a2e3b", label: "Browser"),
                .init(colorHex: "#143d4e", label: "Privacy"),
            ]
        ),
    ]
}
