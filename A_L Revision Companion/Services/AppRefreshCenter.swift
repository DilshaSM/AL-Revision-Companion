import Foundation

@MainActor
final class AppRefreshCenter: ObservableObject {
    @Published private(set) var subjectsToken = UUID()
    @Published private(set) var dashboardToken = UUID()
    @Published private(set) var progressToken = UUID()
    @Published private(set) var recommendationsToken = UUID()

    func didSubmitQuiz() {
        subjectsToken = UUID()
        dashboardToken = UUID()
        progressToken = UUID()
        recommendationsToken = UUID()
    }

    func didOpenLesson() {
        recommendationsToken = UUID()
    }

    func didRecordStudyActivity() {
        dashboardToken = UUID()
        progressToken = UUID()
    }
}
