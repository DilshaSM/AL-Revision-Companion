import SwiftUI

struct QuickRevisionView: View {
    @Environment(\.dismiss) private var dismiss

    private let content: QuickRevisionContent
    private let actions: QuickRevisionViewActions

    init(content: QuickRevisionContent = .placeholder, actions: QuickRevisionViewActions = .init()) {
        self.content = content
        self.actions = actions
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 37) {
                    headerTextSection
                    studyMaterialsSection
                    recentlyViewedSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 48)
            }
        }
        .background(QuickRevisionPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

private extension QuickRevisionView {
    var topBar: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(QuickRevisionPalette.topBarTint)
        }
        .frame(height: 96)
        .overlay(alignment: .leading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(QuickRevisionPalette.ink)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .padding(.leading, 24)
            .padding(.top, 48)
            .padding(.bottom, 16)
        }
    }

    var headerTextSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(content.title)
                .font(AppTypography.quickRevisionTitle)
                .tracking(-0.75)
                .foregroundStyle(QuickRevisionPalette.ink)

            Text(content.subtitle)
                .font(AppTypography.quickRevisionSubtitle)
                .foregroundStyle(QuickRevisionPalette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var studyMaterialsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(content.studyMaterialsTitle.uppercased())
                .font(AppTypography.quickRevisionSectionLabel)
                .tracking(1.2)
                .foregroundStyle(QuickRevisionPalette.sectionLabel)
                .padding(.horizontal, 4)

            ForEach(content.studyMaterials) { material in
                StudyMaterialRow(material: material) {
                    actions.onTapStudyMaterial(material)
                }
            }
        }
        .padding(.top, 16)
    }

    var recentlyViewedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(content.recentlyViewedTitle.uppercased())
                .font(AppTypography.quickRevisionSectionLabel)
                .tracking(1.2)
                .foregroundStyle(QuickRevisionPalette.sectionLabel)
                .padding(.horizontal, 4)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(content.recentlyViewed) { item in
                    RecentlyViewedCard(item: item) {
                        actions.onTapRecentItem(item)
                    }
                }
            }
        }
        .padding(.top, 16)
    }
}

struct QuickRevisionViewActions {
    var onTapStudyMaterial: (QuickRevisionContent.StudyMaterial) -> Void = { _ in }
    var onTapRecentItem: (QuickRevisionContent.RecentItem) -> Void = { _ in }
}

private struct StudyMaterialRow: View {
    let material: QuickRevisionContent.StudyMaterial
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(QuickRevisionPalette.iconBackground)
                        .frame(width: 48, height: 48)

                    Image(systemName: material.symbolName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(QuickRevisionPalette.brand)
                }

                VStack(alignment: .leading, spacing: 3.5) {
                    Text(material.title)
                        .font(AppTypography.quickRevisionListTitle)
                        .foregroundStyle(QuickRevisionPalette.ink)
                        .multilineTextAlignment(.leading)

                    Text(material.subtitle)
                        .font(AppTypography.quickRevisionListSubtitle)
                        .foregroundStyle(QuickRevisionPalette.muted)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 12)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(QuickRevisionPalette.chevron)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct RecentlyViewedCard: View {
    let item: QuickRevisionContent.RecentItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(QuickRevisionPalette.brand)

                    Text(item.relativeTime)
                        .font(AppTypography.quickRevisionRecentMeta)
                        .tracking(0.55)
                        .foregroundStyle(QuickRevisionPalette.brand)
                }

                Text(item.title)
                    .font(AppTypography.quickRevisionRecentTitle)
                    .foregroundStyle(QuickRevisionPalette.ink)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 99, alignment: .topLeading)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private enum QuickRevisionPalette {
    static let canvas = Color(uiColor: .init(red: 249.0 / 255.0, green: 249.0 / 255.0, blue: 254.0 / 255.0, alpha: 1))
    static let topBarTint = Color(uiColor: .init(red: 248.0 / 255.0, green: 250.0 / 255.0, blue: 252.0 / 255.0, alpha: 0.8))
    static let brand = Color(uiColor: .init(red: 0.0 / 255.0, green: 88.0 / 255.0, blue: 188.0 / 255.0, alpha: 1))
    static let ink = Color(uiColor: .init(red: 26.0 / 255.0, green: 28.0 / 255.0, blue: 31.0 / 255.0, alpha: 1))
    static let muted = Color(uiColor: .init(red: 65.0 / 255.0, green: 71.0 / 255.0, blue: 85.0 / 255.0, alpha: 1))
    static let sectionLabel = Color(uiColor: .init(red: 113.0 / 255.0, green: 119.0 / 255.0, blue: 134.0 / 255.0, alpha: 1))
    static let iconBackground = Color(uiColor: .init(red: 239.0 / 255.0, green: 246.0 / 255.0, blue: 255.0 / 255.0, alpha: 1))
    static let chevron = Color(uiColor: .init(red: 126.0 / 255.0, green: 133.0 / 255.0, blue: 148.0 / 255.0, alpha: 1))
}
