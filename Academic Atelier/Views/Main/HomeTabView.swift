import SwiftUI

struct HomeTabView: View {
    @State private var path: [HomeTabRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                actions: .init(
                    onTapQuickTool: handleQuickToolTap
                )
            )
            .navigationDestination(for: HomeTabRoute.self) { destination in
                switch destination {
                case .quickRevision:
                    QuickRevisionView(
                        actions: .init(
                            onTapStudyMaterial: handleStudyMaterialTap
                        )
                    )
                case let .topicSelection(subject):
                    QuickRevisionTopicSelectionView(
                        subject: subject,
                        actions: .init(
                            onTapTopic: handleTopicTap,
                            onTapRecentTopic: { handleRecentTopicTap($0, in: subject) }
                        )
                    )
                case let .topicContent(topic):
                    QuickRevisionContentView(topic: topic)
                }
            }
        }
    }

    private func handleQuickToolTap(_ tool: HomeDashboardContent.QuickToolContent) {
        guard let destination = tool.destination else { return }

        switch destination {
        case .quickRevision:
            path.append(.quickRevision)
        }
    }

    private func handleStudyMaterialTap(_ subject: QuickRevisionSubject) {
        path.append(.topicSelection(subject))
    }

    private func handleTopicTap(_ topic: QuickRevisionSubject.Topic) {
        path.append(.topicContent(topic))
    }

    private func handleRecentTopicTap(_ recentTopic: QuickRevisionSubject.RecentTopic, in subject: QuickRevisionSubject) {
        guard let topic = subject.topic(withID: recentTopic.id) else { return }
        path.append(.topicContent(topic))
    }
}

private enum HomeTabRoute: Hashable {
    case quickRevision
    case topicSelection(QuickRevisionSubject)
    case topicContent(QuickRevisionSubject.Topic)
}
