import SwiftUI

struct RootView: View {
    @EnvironmentObject var session: SessionViewModel

    var body: some View {
        Group {
            if session.isRestoringSession {
                ProgressView("Loading session...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColors.background.ignoresSafeArea())
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
    }
}
