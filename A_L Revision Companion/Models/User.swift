import Foundation

struct User: Codable, Equatable {
    let id: Int
    var fullName: String
    var email: String
    var streamId: Int?
    var registrationNumber: String
    var isActive: Bool
    var createdAt: Date?
    var updatedAt: Date?
    var selectedStream: Stream?
    var preference: ProfileSettings?

    private enum CodingKeys: String, CodingKey {
        case id
        case fullName
        case email
        case streamId
        case registrationNumber
        case isActive
        case createdAt
        case updatedAt
        case selectedStream = "stream"
        case preference
    }
}
