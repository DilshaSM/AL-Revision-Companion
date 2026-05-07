import Foundation

struct Stream: Codable, Equatable, Hashable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let orderIndex: Int?
    let isActive: Bool?

    init(
        id: Int,
        name: String,
        description: String? = nil,
        orderIndex: Int? = nil,
        isActive: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.orderIndex = orderIndex
        self.isActive = isActive
    }

    var displayName: String {
        normalizedName.capitalized
    }

    var assetName: String {
        switch normalizedName {
        case "SCIENCE":
            return "stream_science"
        case "COMMERCE":
            return "stream_commerce"
        case "ARTS":
            return "stream_arts"
        case "TECHNOLOGY":
            return "stream_technology"
        default:
            return "stream_science"
        }
    }

    var profileDisplayTitle: String {
        switch normalizedName {
        case "SCIENCE":
            return "Physical Science"
        case "COMMERCE":
            return "Commerce"
        case "ARTS":
            return "Arts"
        case "TECHNOLOGY":
            return "Technology"
        default:
            return displayName
        }
    }

    var subjectSummary: String {
        switch normalizedName {
        case "SCIENCE":
            return "Combined Maths, Physics,\nChemistry"
        case "COMMERCE":
            return "Accounting, Economics,\nBusiness Studies"
        case "ARTS":
            return "History, Political Science,\nMedia Studies"
        case "TECHNOLOGY":
            return "Engineering Tech, Science for Tech,\nICT"
        default:
            return description ?? "Academic stream selected"
        }
    }

    private var normalizedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }
}
