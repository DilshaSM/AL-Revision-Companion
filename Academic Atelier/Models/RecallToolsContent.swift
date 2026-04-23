import Foundation

struct RecallToolsContent {
    var recentItems: [RecentItem]

    static let placeholder = RecallToolsContent(
        recentItems: [
            .init(
                id: "physics-thermodynamics-flashcards",
                title: "Physics – Thermodynamics\nFlashcards",
                detail: "Last practiced 2h ago",
                iconName: "clock.arrow.circlepath",
                accent: .blue
            ),
            .init(
                id: "biology-genetics-audio",
                title: "Biology – Genetics Audio Notes",
                detail: "Last practiced Yesterday",
                iconName: "clock.arrow.circlepath",
                accent: .orange
            )
        ]
    )
}

extension RecallToolsContent {
    struct RecentItem: Identifiable, Hashable {
        var id: String
        var title: String
        var detail: String
        var iconName: String
        var accent: Accent
    }

    enum Accent: Hashable {
        case blue
        case orange
    }
}
