import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeTabView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .accessibilityHint("Open the home dashboard.")

            SubjectsTabView()
                .tabItem {
                    Label("Subjects", systemImage: "book.fill")
                }
                .accessibilityHint("Open your subjects.")

            ProgressRootView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
                .accessibilityHint("Open revision progress.")

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .accessibilityHint("Open your profile.")
        }
    }
}
