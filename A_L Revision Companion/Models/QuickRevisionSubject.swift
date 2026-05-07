import Foundation

struct QuickRevisionSubject: Identifiable, Hashable {
    let id: Int
    let title: String
    let materialSubtitle: String
    let symbolName: String
    let tintHex: String?

    init(apiSubject: APIQuickRevisionSubject) {
        id = apiSubject.id
        title = apiSubject.displayName
        materialSubtitle = "Quick revision topics"
        symbolName = Self.symbolName(for: apiSubject.icon)
        tintHex = apiSubject.color
    }

    static func symbolName(for backendIcon: String?) -> String {
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
        case "desktopcomputer":
            return "desktopcomputer"
        default:
            return "doc.text.fill"
        }
    }
}

struct QuickRevisionTopic: Identifiable, Hashable {
    let id: Int
    let baseTopicID: Int
    let title: String
    let subtitle: String?
    let symbolName: String

    init(apiTopic: APIQuickRevisionTopicListItem, symbolName: String) {
        id = apiTopic.id
        baseTopicID = apiTopic.topicId
        title = apiTopic.title
        subtitle = apiTopic.subtitle
        self.symbolName = symbolName
    }
}

struct QuickRevisionTopicDetailContent: Hashable {
    let id: Int
    let title: String
    let subtitle: String?
    let subjectID: Int
    let subjectName: String
    let sections: [Section]
    let emptyStateMessage: String

    init(apiTopic: APIQuickRevisionTopicDetail) {
        id = apiTopic.id
        title = apiTopic.title
        subtitle = apiTopic.subtitle
        subjectID = apiTopic.subjectId
        subjectName = apiTopic.subjectName
        sections = apiTopic.sections
            .sorted { $0.orderIndex < $1.orderIndex }
            .map(Section.init)
        emptyStateMessage = "No revision notes available for this topic yet."
    }
}

extension QuickRevisionTopicDetailContent {
    struct Section: Identifiable, Hashable {
        let id: Int
        let type: String
        let title: String
        let content: String
        let orderIndex: Int

        init(apiSection: APIQuickRevisionTopicSection) {
            id = apiSection.id
            type = apiSection.sectionType
            title = apiSection.title
            content = apiSection.content
            orderIndex = apiSection.orderIndex
        }

        var labelText: String {
            switch normalizedType {
            case "KEY_DEFINITION":
                return "Key Definition"
            case "FORMULA":
                return "Formula"
            case "LAW_PRINCIPLE":
                return "Law & Principle"
            case "QUICK_SUMMARY":
                return "Quick Summary"
            default:
                return normalizedType
                    .lowercased()
                    .replacingOccurrences(of: "_", with: " ")
                    .capitalized
            }
        }

        var style: Style {
            switch normalizedType {
            case "KEY_DEFINITION":
                return .definition
            case "FORMULA":
                return .formula
            case "LAW_PRINCIPLE":
                return .principle
            case "QUICK_SUMMARY":
                return .summary
            default:
                return .generic
            }
        }

        private var normalizedType: String {
            type.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        }
    }

    enum Style: Hashable {
        case definition
        case formula
        case principle
        case summary
        case generic
    }
}
