import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeTabView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(MainTabDestination.home)
                .accessibilityHint("Open the home dashboard.")

            SubjectsTabView()
                .tabItem {
                    Label("Subjects", systemImage: "book.fill")
                }
                .tag(MainTabDestination.subjects)
                .accessibilityHint("Open your subjects.")

            ProgressRootView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
                .tag(MainTabDestination.progress)
                .accessibilityHint("Open revision progress.")

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(MainTabDestination.profile)
                .accessibilityHint("Open your profile.")
        }
    }
}
