import Foundation

@MainActor
final class AppRefreshCenter: ObservableObject {
    @Published private(set) var subjectsToken = UUID()
    @Published private(set) var dashboardToken = UUID()

    func didSubmitQuiz() {
        subjectsToken = UUID()
        dashboardToken = UUID()
    }
}
