import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var session: SessionViewModel
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        Group {
            if session.isRestoringSession {
                ProgressView("Loading session...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColors.background.ignoresSafeArea())
                    .accessibilityLabel("Loading session")
            } else {
                switch session.authRoute {
                case .signIn:
                    NavigationStack {
                        SignInView()
                    }

                case .signUp:
                    NavigationStack {
                        SignUpView()
                    }

                case .streamSelection:
                    NavigationStack {
                        StreamSelectionView()
                    }

                case .main:
                    MainTabView()
                }
            }
        }
        .task {
            session.configure(modelContext: modelContext)
        }
        .onOpenURL { url in
            guard let deepLink = AppDeepLink.parse(url) else { return }

            if session.currentUser == nil {
                session.showSignIn()
                return
            }

            if session.currentUser?.streamId == nil {
                Task {
                    await session.ensureAvailableStreams()
                }
                return
            }

            router.handle(deepLink)
        }
    }
}
