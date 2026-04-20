import SwiftUI

struct RootView: View {
    @EnvironmentObject var session: SessionViewModel

    var body: some View {
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
