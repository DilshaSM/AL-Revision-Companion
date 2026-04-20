import SwiftUI

struct StreamSelectionView: View {
    @EnvironmentObject var session: SessionViewModel

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    headerSection
                    streamListSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 36)
                .padding(.bottom, 32)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Sections
private extension StreamSelectionView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Select Your\nStream")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Choose your academic focus to unlock curated learning paths tailored for your professional future.")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
        }
    }

    var streamListSection: some View {
        VStack(spacing: 18) {
            StreamSelectionCard(
                title: "Science",
                subtitle: "STEM focused mastery. (Physics, Chemistry, Biology)",
                iconName: "stream_science"
            ) {
                session.updateSelectedStream(.science)
            }

            StreamSelectionCard(
                title: "Commerce",
                subtitle: "Finance & global markets. (Accounting, Economics, Business)",
                iconName: "stream_commerce"
            ) {
                session.updateSelectedStream(.commerce)
            }

            StreamSelectionCard(
                title: "Arts",
                subtitle: "Thinking, history & media. (History, Logic, Media, Languages)",
                iconName: "stream_arts"
            ) {
                session.updateSelectedStream(.arts)
            }

            StreamSelectionCard(
                title: "Technology",
                subtitle: "Software & innovation. (Eng Tech, Science for Tech, ICT)",
                iconName: "stream_technology"
            ) {
                session.updateSelectedStream(.technology)
            }
        }
    }
}
