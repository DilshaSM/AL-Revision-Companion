import SwiftUI

struct HomeTabView: View {
    @State private var route: HomeTabRoute?

    var body: some View {
        NavigationStack {
            HomeView(
                actions: .init(
                    onTapQuickTool: handleQuickToolTap
                )
            )
            .navigationDestination(item: $route) { destination in
                switch destination {
                case .quickRevision:
                    QuickRevisionView()
                }
            }
        }
    }

    private func handleQuickToolTap(_ tool: HomeDashboardContent.QuickToolContent) {
        guard tool.id == "quick-revision" else { return }
        route = .quickRevision
    }
}

private enum HomeTabRoute: String, Identifiable {
    case quickRevision

    var id: String { rawValue }
}
