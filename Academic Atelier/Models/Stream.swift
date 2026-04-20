import Foundation

enum Stream: String, CaseIterable, Codable, Identifiable {
    case science = "Science"
    case commerce = "Commerce"
    case arts = "Arts"
    case technology = "Technology"

    var id: String { rawValue }
}
