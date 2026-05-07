import Foundation

struct PreferencesPayload: Decodable {
    let preferences: ProfileSettings
}

struct UpdatePreferencesRequest: Encodable {
    let localNotificationsEnabled: Bool?
    let biometricEnabled: Bool?
}
