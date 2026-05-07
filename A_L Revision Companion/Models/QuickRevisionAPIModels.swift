import Foundation

struct QuickRevisionSubjectsPayload: Decodable {
    let subjects: [APIQuickRevisionSubject]
}

struct APIQuickRevisionSubject: Decodable, Hashable, Identifiable {
    let id: Int
    let name: String
    let displayName: String
    let icon: String?
    let color: String?
}

struct QuickRevisionTopicsPayload: Decodable {
    let subject: APIQuickRevisionTopicsSubject
}

struct APIQuickRevisionTopicsSubject: Decodable, Hashable {
    let id: Int
    let displayName: String
    let quickRevisionTopics: [APIQuickRevisionTopicListItem]
}

struct APIQuickRevisionTopicListItem: Decodable, Hashable, Identifiable {
    let id: Int
    let title: String
    let subtitle: String?
    let topicId: Int
}

struct QuickRevisionTopicDetailPayload: Decodable {
    let topic: APIQuickRevisionTopicDetail
}

struct APIQuickRevisionTopicDetail: Decodable, Hashable {
    let id: Int
    let title: String
    let subtitle: String?
    let subjectId: Int
    let subjectName: String
    let sections: [APIQuickRevisionTopicSection]
}

struct APIQuickRevisionTopicSection: Decodable, Hashable, Identifiable {
    let id: Int
    let sectionType: String
    let title: String
    let content: String
    let orderIndex: Int
}
