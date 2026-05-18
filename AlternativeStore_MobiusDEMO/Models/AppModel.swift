import Foundation
import UIKit

struct ScreenshotPlaceholder: Codable, Sendable {
    let colorHex: String
    let label: String
}

/// Represents a single app available in the marketplace catalog.
/// Mirrors a typical backend app DTO.
///
/// Описывает одно приложение, доступное в каталоге маркетплейса.
/// Соответствует типичному DTO приложения на бэкенде.
struct AppModel: Identifiable, Codable, Sendable {
    let id: Int
    let name: String
    let bundleId: String
    let developerName: String
    let description: String
    let shortVersionString: String
    let iconURL: URL?
    let screenshotURLs: [URL]
    let price: String
    let isFree: Bool

    /// Apple-assigned identifiers — required for MarketplaceKit.
    /// Идентификаторы Apple, обязательные для MarketplaceKit.
    let appleItemId: Int
    let appleVersionId: Int

    /// URL to the Alternative Distribution Package hosted on your server.
    /// URL до Alternative Distribution Package на вашем сервере.
    let alternativeDistributionPackageURL: URL?

    /// App size in bytes (for display: "45 MB").
    /// Размер приложения в байтах (для отображения: "45 MB").
    let sizeBytes: Int64

    /// Category label shown in the UI.
    /// Категория, отображаемая в интерфейсе.
    let category: String

    /// Hex color for the icon background (mock data only).
    /// Hex-цвет фона иконки (только для мок-данных).
    let iconColorHex: String?

    /// Emoji or short text rendered on the icon (mock data only).
    /// Эмодзи или короткий текст на иконке (только для мок-данных).
    let iconEmoji: String?

    /// Placeholder screenshot colors + labels (mock data only, no network needed).
    /// Цвета и подписи заглушек скриншотов (только для мок-данных, сеть не нужна).
    let screenshotPlaceholders: [ScreenshotPlaceholder]?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case bundleId = "bundle_id"
        case developerName = "developer_name"
        case description
        case shortVersionString = "short_version_string"
        case iconURL = "icon_url"
        case screenshotURLs = "screenshot_urls"
        case price
        case isFree = "is_free"
        case appleItemId = "apple_item_id"
        case appleVersionId = "apple_version_id"
        case alternativeDistributionPackageURL = "alternative_distribution_package_url"
        case sizeBytes = "size_bytes"
        case category
        case iconColorHex = "icon_color_hex"
        case iconEmoji = "icon_emoji"
        case screenshotPlaceholders = "screenshot_placeholders"
    }
}

extension AppModel {
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: sizeBytes)
    }

    var priceLabel: String {
        isFree ? "Free" : price
    }

    /// Resolved UIColor from `iconColorHex`, fallback to system tint.
    /// UIColor из `iconColorHex`, по умолчанию — системный tint.
    nonisolated var iconColor: UIColor {
        guard let hex = iconColorHex else { return .systemBlue }
        var rgb: UInt64 = 0
        Scanner(string: hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")))
            .scanHexInt64(&rgb)
        return UIColor(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}
