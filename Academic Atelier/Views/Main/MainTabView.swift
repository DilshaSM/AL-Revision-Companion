import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeTabView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            SubjectsPlaceholderView()
                .tabItem {
                    Label("Subjects", systemImage: "book.fill")
                }

            ProgressPlaceholderView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}
