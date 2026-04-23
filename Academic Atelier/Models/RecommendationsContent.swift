import Foundation

struct RecommendationsContent: Hashable {
    var eyebrow: String
    var title: String
    var summarySegments: [SummarySegment]
    var overallProficiency: OverallProficiency
    var sectionTitle: String
    var sectionActionTitle: String
    var pathways: [Pathway]

    static let placeholder = RecommendationsContent(
        eyebrow: "Performance Analysis",
        title: "Focus on\nFoundations",
        summarySegments: [
            .init(text: "Based on your recent Physics and\nMathematics quizzes, we've identified key\ngaps in "),
            .init(text: "Thermodynamics", isEmphasized: true),
            .init(text: " and "),
            .init(text: "Integration", isEmphasized: true),
            .init(text: ".")
        ],
        overallProficiency: .init(
            title: "Overall Proficiency",
            scoreText: "75%",
            scoreValue: 0.75,
            message: "Strengthening these topics\nwill boost your projected\nscore by 18%."
        ),
        sectionTitle: "Priority Pathways",
        sectionActionTitle: "Sorted by Impact",
        pathways: [
            .init(
                id: "thermodynamics-second-law",
                priority: .critical,
                title: "Thermodynamics: Second\nLaw",
                summary: "Accuracy fell below 45% in entropy\ncalculations. This topic accounts for 12% of\nthe final paper.",
                primaryActionTitle: "Start Revision",
                durationText: "45 MIN"
            ),
            .init(
                id: "definite-integrals",
                priority: .medium,
                title: "Definite Integrals",
                summary: "Refine substitution methods for complex\ntrigonometric functions.",
                curriculumProgress: .init(
                    label: "Curriculum Progress",
                    valueText: "2 of 5 Units",
                    progress: 0.40
                ),
                reviewHistoryTitle: "Review History",
                reviewHistory: [
                    .init(id: "limit-theorem", iconName: "sum", title: "Limit Theorem", timeAgoText: "4 DAYS AGO"),
                    .init(id: "electrostatics", iconName: "bolt.fill", title: "Electrostatics", timeAgoText: "1 WEEK AGO")
                ]
            )
        ]
    )
}

extension RecommendationsContent {
    struct SummarySegment: Hashable {
        var text: String
        var isEmphasized: Bool = false
    }

    struct OverallProficiency: Hashable {
        var title: String
        var scoreText: String
        var scoreValue: Double
        var message: String
    }

    struct Pathway: Identifiable, Hashable {
        enum Priority: String, Hashable {
            case critical
            case medium

            var label: String {
                switch self {
                case .critical:
                    return "Critical Focus"
                case .medium:
                    return "Medium Impact"
                }
            }
        }

        var id: String
        var priority: Priority
        var title: String
        var summary: String
        var primaryActionTitle: String? = nil
        var durationText: String? = nil
        var curriculumProgress: CurriculumProgress? = nil
        var reviewHistoryTitle: String? = nil
        var reviewHistory: [ReviewHistoryItem] = []
    }

    struct CurriculumProgress: Hashable {
        var label: String
        var valueText: String
        var progress: Double
    }

    struct ReviewHistoryItem: Identifiable, Hashable {
        var id: String
        var iconName: String
        var title: String
        var timeAgoText: String
    }
}
