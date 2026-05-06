import Foundation

struct CachedWidgetSummary: Codable {
    let continueLearning: CachedContinueLearning?
    let todaysFocus: CachedTodaysFocus?
    let revisionProgress: CachedRevisionProgress
    let updatedAt: Date
}

struct CachedContinueLearning: Codable {
    let title: String
    let subtitle: String
    let progressPercent: Int
    let lessonId: Int?
    let topicId: Int?
    let subjectId: Int?
}

struct CachedTodaysFocus: Codable {
    let title: String
    let subtitle: String
    let topicId: Int?
    let subjectId: Int?
}

struct CachedRevisionProgress: Codable {
    let weeklyGoalPercent: Int
    let focusTimeMinutes: Int
    let activeDays: Int
    let chaptersCompleted: Int
}

extension CachedWidgetSummary {
    var continueLearningURL: URL {
        guard let item = continueLearning else {
            return homeURL
        }

        var components = URLComponents()
        components.scheme = "academicatelier"
        components.host = "continue-learning"
        components.queryItems = [
            item.subjectId.map { URLQueryItem(name: "subjectId", value: "\($0)") },
            item.lessonId.map { URLQueryItem(name: "lessonId", value: "\($0)") },
            item.topicId.map { URLQueryItem(name: "topicId", value: "\($0)") }
        ].compactMap { $0 }

        return components.url ?? homeURL
    }

    var todaysFocusURL: URL {
        guard let item = todaysFocus else {
            return homeURL
        }

        var components = URLComponents()
        components.scheme = "academicatelier"
        components.host = "recommendation"
        components.queryItems = [
            item.subjectId.map { URLQueryItem(name: "subjectId", value: "\($0)") },
            item.topicId.map { URLQueryItem(name: "topicId", value: "\($0)") }
        ].compactMap { $0 }

        return components.url ?? homeURL
    }

    var progressURL: URL {
        URL(string: "academicatelier://progress")!
    }

    var homeURL: URL {
        URL(string: "academicatelier://home")!
    }
}
