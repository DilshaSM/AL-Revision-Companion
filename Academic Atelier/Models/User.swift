import Foundation

struct User: Codable, Equatable {
    let id: UUID
    var fullName: String
    var email: String
    var selectedStream: Stream?
}
