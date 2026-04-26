import SwiftUI

struct QuickRevisionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionViewModel
    @StateObject private var viewModel = QuickRevisionViewModel()

    private let actions: QuickRevisionViewActions

    init(actions: QuickRevisionViewActions = .init()) {
        self.actions = actions
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 37) {
                    headerTextSection
                    statusSection
                    studyMaterialsSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 48)
            }
        }
        .background(QuickRevisionPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await load(forceRefresh: false)
        }
        .refreshable {
            await load(forceRefresh: true)
        }
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
            Text(viewModel.content?.title ?? "Quick Revision")
                .font(AppTypography.quickRevisionTitle)
                .tracking(-0.75)
                .foregroundStyle(QuickRevisionPalette.ink)

            Text(viewModel.content?.subtitle ?? "Review key concepts, formulas, and summaries by subject.")
                .font(AppTypography.quickRevisionSubtitle)
                .foregroundStyle(QuickRevisionPalette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    var statusSection: some View {
        if viewModel.isLoading && viewModel.content == nil {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading quick revision subjects...")
                    .font(.footnote)
                    .foregroundStyle(QuickRevisionPalette.muted)
            }
        } else if !viewModel.errorMessage.isEmpty && viewModel.content == nil {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.errorMessage)
                    .font(.footnote)
                    .foregroundStyle(SubjectsPalette.resultIncorrect)

                Button("Retry") {
                    Task {
                        await load(forceRefresh: true)
                    }
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(QuickRevisionPalette.brand)
            }
        } else if viewModel.isLoading {
            Text("Refreshing quick revision subjects...")
                .font(.footnote)
                .foregroundStyle(QuickRevisionPalette.muted)
        }
    }

    var studyMaterialsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text((viewModel.content?.studyMaterialsTitle ?? "Study Materials").uppercased())
                .font(AppTypography.quickRevisionSectionLabel)
                .tracking(1.2)
                .foregroundStyle(QuickRevisionPalette.sectionLabel)
                .padding(.horizontal, 4)

            if let content = viewModel.content, content.studyMaterials.isEmpty {
                Text(content.emptyStateMessage)
                    .font(.footnote)
                    .foregroundStyle(QuickRevisionPalette.muted)
                    .padding(.horizontal, 4)
            } else if let content = viewModel.content {
                ForEach(content.studyMaterials) { material in
                    StudyMaterialRow(material: material) {
                        actions.onTapStudyMaterial(material)
                    }
                }
            }
        }
        .padding(.top, 16)
    }

    func load(forceRefresh: Bool) async {
        await viewModel.load(forceRefresh: forceRefresh)

        if viewModel.requiresSignOut {
            session.signOut()
        }
    }
}

struct QuickRevisionViewActions {
    var onTapStudyMaterial: (QuickRevisionSubject) -> Void = { _ in }
}

private struct StudyMaterialRow: View {
    let material: QuickRevisionSubject
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

                    Text(material.materialSubtitle)
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
