import Foundation

enum AppDeepLink: Equatable {
    case home
    case progress
    case subjects
    case subject(subjectId: Int)
    case continueLearning(subjectId: Int?, lessonId: Int?, topicId: Int?)
    case recommendation(subjectId: Int?, topicId: Int?)
}

extension AppDeepLink {
    static func parse(_ url: URL) -> AppDeepLink? {
        guard url.scheme?.lowercased() == "academicatelier" else {
            return nil
        }

        let host = url.host?.lowercased()
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []

        func intValue(_ name: String) -> Int? {
            queryItems
                .first(where: { $0.name == name })?
                .value
                .flatMap(Int.init)
        }

        switch host {
        case "home":
            return .home
        case "progress":
            return .progress
        case "subjects":
            return .subjects
        case "subject":
            guard let subjectId = intValue("subjectId") else {
                return .subjects
            }
            return .subject(subjectId: subjectId)
        case "continue-learning":
            return .continueLearning(
                subjectId: intValue("subjectId"),
                lessonId: intValue("lessonId"),
                topicId: intValue("topicId")
            )
        case "recommendation":
            return .recommendation(
                subjectId: intValue("subjectId"),
                topicId: intValue("topicId")
            )
        default:
            return nil
        }
    }
}
