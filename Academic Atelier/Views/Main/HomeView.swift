import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: SessionViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Welcome, \(session.currentUser?.fullName ?? "Student")")
                        .font(.title.bold())

                    Text("Your stream: \(session.currentUser?.selectedStream?.rawValue ?? "Not Selected")")
                        .foregroundStyle(.secondary)

                    SectionHeader(title: "Continue Learning")
                    placeholderCard("Your personalized revision journey will appear here.")

                    SectionHeader(title: "Today's Focus")
                    placeholderCard("Recommended topic and revision shortcuts will appear here.")
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle("Home")
        }
    }

    @ViewBuilder
    private func placeholderCard(_ text: String) -> some View {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
            .fill(AppColors.cardBackground)
            .frame(height: 120)
            .overlay(
                Text(text)
                    .foregroundStyle(.secondary)
                    .padding()
            )
            .shadow(
                color: .black.opacity(AppTheme.cardShadowOpacity),
                radius: 8,
                x: 0,
                y: 4
            )
    }
}
