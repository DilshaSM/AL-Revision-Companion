import Foundation

struct ProfileSettings: Codable, Equatable {
    var isFaceIDEnabled: Bool
    var areNotificationsEnabled: Bool
    var updatedAt: Date?

    init(
        isFaceIDEnabled: Bool = false,
        areNotificationsEnabled: Bool = true,
        updatedAt: Date? = nil
    ) {
        self.isFaceIDEnabled = isFaceIDEnabled
        self.areNotificationsEnabled = areNotificationsEnabled
        self.updatedAt = updatedAt
    }

    private enum CodingKeys: String, CodingKey {
        case isFaceIDEnabled = "biometricEnabled"
        case areNotificationsEnabled = "localNotificationsEnabled"
        case updatedAt
    }
}
