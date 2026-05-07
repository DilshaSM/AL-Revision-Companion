import SwiftUI

struct ProgressRootView: View {
    @State private var path: [ProgressRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            ProgressTabView(
                actions: .init(
                    onTapSubjectMastery: { mastery in
                        path.append(.recommendations(mastery))
                    }
                )
            )
            .navigationDestination(for: ProgressRoute.self) { route in
                switch route {
                case let .recommendations(subject):
                    RecommendationsView(preferredSubject: subject)
                }
            }
        }
    }
}

private enum ProgressRoute: Hashable {
    case recommendations(ProgressTabContent.SubjectMastery)
}
