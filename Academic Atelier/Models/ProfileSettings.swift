import Foundation

struct ProfileSettings: Codable, Equatable {
    var isFaceIDEnabled: Bool = false
    var areNotificationsEnabled: Bool = true
}
