import Foundation

struct QuickRevisionContent {
    var title: String
    var subtitle: String
    var studyMaterialsTitle: String
    var studyMaterials: [QuickRevisionSubject]
    var recentlyViewedTitle: String
    var recentlyViewed: [RecentItem]

    static let placeholder = QuickRevisionContent(
        title: "Quick Revision",
        subtitle: "Review key concepts, formulas, and summaries by subject.",
        studyMaterialsTitle: "Study Materials",
        studyMaterials: QuickRevisionSubject.placeholders,
        recentlyViewedTitle: "Recently Viewed",
        recentlyViewed: [
            .init(id: "organic-chemistry", relativeTime: "2 HRS AGO", title: "Organic Chemistry\nMechanism"),
            .init(id: "integration-rules", relativeTime: "YESTERDAY", title: "Integration Rules\nv2.1")
        ]
    )
}

extension QuickRevisionContent {
    struct RecentItem: Identifiable, Hashable {
        var id: String
        var relativeTime: String
        var title: String
    }
}
