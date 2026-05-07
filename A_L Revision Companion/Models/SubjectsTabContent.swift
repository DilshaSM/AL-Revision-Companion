import Foundation

struct SubjectsTabContent: Hashable {
    var title: String
    var subtitle: String
    var streamName: String?
    var subjectsSectionTitle: String
    var subjects: [Subject]

    static func build(subjects: [APISubject], user: User?) -> SubjectsTabContent {
        let orderedSubjects = subjects
            .sorted { $0.orderIndex < $1.orderIndex }
            .map { Subject(apiSubject: $0) }

        let streamName = user?.selectedStream?.displayName

        return SubjectsTabContent(
            title: "Your Subjects",
            subtitle: streamName.map { "Stream: \($0)" } ?? "Select a stream to load your curriculum.",
            streamName: streamName,
            subjectsSectionTitle: "Active Curriculum",
            subjects: orderedSubjects
        )
    }
}

extension SubjectsTabContent {
    struct Subject: Identifiable, Hashable {
        var id: Int
        var title: String
        var subtitle: String
        var iconSystemName: String
        var tintHex: String?
        var streamId: Int

        init(apiSubject: APISubject) {
            id = apiSubject.id
            title = apiSubject.displayName
            subtitle = apiSubject.name.replacingOccurrences(of: "_", with: " ").capitalized
            iconSystemName = Self.symbolName(for: apiSubject.icon)
            tintHex = apiSubject.color
            streamId = apiSubject.streamId
        }

        private static func symbolName(for backendIcon: String?) -> String {
            switch backendIcon?.lowercased() {
            case "flask":
                return "flask.fill"
            case "atom":
                return "atom"
            case "bolt":
                return "bolt.fill"
            case "leaf":
                return "leaf.fill"
            case "function":
                return "function"
            case "book":
                return "book.closed.fill"
            default:
                return "book.fill"
            }
        }
    }
}
