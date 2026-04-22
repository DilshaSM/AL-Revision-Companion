import Foundation

struct QuickRevisionContent {
    var title: String
    var subtitle: String
    var studyMaterialsTitle: String
    var studyMaterials: [StudyMaterial]
    var recentlyViewedTitle: String
    var recentlyViewed: [RecentItem]

    static let placeholder = QuickRevisionContent(
        title: "Quick Revision",
        subtitle: "Review key concepts, formulas, and summaries by subject.",
        studyMaterialsTitle: "Study Materials",
        studyMaterials: [
            .init(id: "combined-maths", title: "Combined Mathematics", subtitle: "Key Notes", symbolName: "function"),
            .init(id: "physics", title: "Physics", subtitle: "Formula Sheet", symbolName: "bolt"),
            .init(id: "chemistry", title: "Chemistry", subtitle: "Quick Summary", symbolName: "flask"),
            .init(id: "biology", title: "Biology", subtitle: "Key Definitions", symbolName: "leaf"),
            .init(id: "ict", title: "ICT", subtitle: "Essential Concepts", symbolName: "desktopcomputer")
        ],
        recentlyViewedTitle: "Recently Viewed",
        recentlyViewed: [
            .init(id: "organic-chemistry", relativeTime: "2 HRS AGO", title: "Organic Chemistry\nMechanism"),
            .init(id: "integration-rules", relativeTime: "YESTERDAY", title: "Integration Rules\nv2.1")
        ]
    )
}

extension QuickRevisionContent {
    struct StudyMaterial: Identifiable, Hashable {
        var id: String
        var title: String
        var subtitle: String
        var symbolName: String
    }

    struct RecentItem: Identifiable, Hashable {
        var id: String
        var relativeTime: String
        var title: String
    }
}
