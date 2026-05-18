import Foundation

/// Response from `GET /v1/versions/{appleVersionId}/install`.
///
/// The `installVerificationToken` is a JWT signed by the marketplace backend
/// with the private key registered in App Store Connect. MarketplaceKit uses
/// it to verify that the install request is legitimate.
///
/// Ответ на запрос `GET /v1/versions/{appleVersionId}/install`.
/// `installVerificationToken` — JWT, подписанный приватным ключом маркетплейса,
/// зарегистрированным в App Store Connect. MarketplaceKit использует его
/// для подтверждения легитимности установки.
struct AppInstallMetadata: Codable, Sendable {
    let installVerificationToken: String

    private enum CodingKeys: String, CodingKey {
        case installVerificationToken = "install_verification_token"
    }
}
