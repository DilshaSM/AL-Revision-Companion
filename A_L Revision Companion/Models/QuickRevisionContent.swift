import Foundation

struct QuickRevisionContent: Hashable {
    let title: String
    let subtitle: String
    let studyMaterialsTitle: String
    let studyMaterials: [QuickRevisionSubject]
    let emptyStateMessage: String

    static func build(subjects: [APIQuickRevisionSubject]) -> QuickRevisionContent {
        QuickRevisionContent(
            title: "Quick Revision",
            subtitle: "Review key concepts, formulas, and summaries by subject.",
            studyMaterialsTitle: "Study Materials",
            studyMaterials: subjects.map(QuickRevisionSubject.init),
            emptyStateMessage: "No quick revision subjects available yet."
        )
    }
}
