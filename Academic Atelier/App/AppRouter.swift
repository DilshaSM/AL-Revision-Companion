import Foundation

enum AppRoute {
    case signIn
    case signUp
    case streamSelection
    case main
}

enum MainTabDestination: Hashable {
    case home
    case subjects
    case progress
    case profile
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var selectedTab: MainTabDestination = .home
    @Published var pendingDeepLink: AppDeepLink?

    func handle(_ deepLink: AppDeepLink) {
        switch deepLink {
        case .home:
            selectedTab = .home
            pendingDeepLink = nil
        case .progress:
            selectedTab = .progress
            pendingDeepLink = nil
        case .subjects:
            selectedTab = .subjects
            pendingDeepLink = nil
        case .subject, .continueLearning, .recommendation:
            selectedTab = .subjects
            pendingDeepLink = deepLink
        }
    }

    func clearPendingDeepLink() {
        pendingDeepLink = nil
    }
}
