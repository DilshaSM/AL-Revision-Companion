import Foundation

struct ProfileSettings: Codable, Equatable {
    var isFaceIDEnabled: Bool
    var areNotificationsEnabled: Bool

    init(
        isFaceIDEnabled: Bool = false,
        areNotificationsEnabled: Bool = true
    ) {
        self.isFaceIDEnabled = isFaceIDEnabled
        self.areNotificationsEnabled = areNotificationsEnabled
    }

    private enum CodingKeys: String, CodingKey {
        case isFaceIDEnabled = "biometricEnabled"
        case areNotificationsEnabled = "localNotificationsEnabled"
    }
}
