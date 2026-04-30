import SwiftUI

struct QuickRevisionContentView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionViewModel
    @EnvironmentObject private var refreshCenter: AppRefreshCenter
    @StateObject private var viewModel = QuickRevisionContentViewModel()
    @AccessibilityFocusState private var focusedElement: FocusTarget?

    private let topic: QuickRevisionTopic

    private enum FocusTarget: Hashable {
        case title
        case status
    }

    init(topic: QuickRevisionTopic) {
        self.topic = topic
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    headerSection
                    statusSection
                    sectionsContent
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .padding(.bottom, 48)
            }
        }
        .background(QuickRevisionPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task(id: topic.id) {
            await loadTopic()
        }
        .onAppear {
            focusedElement = .title
        }
        .onChange(of: viewModel.errorMessage) { _, message in
            guard !message.isEmpty else { return }
            focusedElement = .status
            Task { @MainActor in
                AccessibilitySupport.announce(message)
            }
        }
    }
}

private extension QuickRevisionContentView {
    var topBar: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(QuickRevisionPalette.topBarTint)

            Rectangle()
                .fill(.black.opacity(0.03))
                .frame(height: 0.5)
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
            .accessibilityLabel("Go back")
            .accessibilityHint("Return to the topic list.")
            .padding(.leading, 28)
            .padding(.top, 48)
            .padding(.bottom, 16)
        }
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.content?.title ?? topic.title)
                .font(AppTypography.quickRevisionTopicTitle)
                .tracking(-0.9)
                .foregroundStyle(QuickRevisionPalette.ink)
                .accessibilityHeader()
                .accessibilityFocused($focusedElement, equals: .title)

            if let content = viewModel.content {
                if let subtitle = content.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppTypography.quickRevisionContentSubtitle)
                        .foregroundStyle(QuickRevisionPalette.muted)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(content.subjectName)
                        .font(AppTypography.quickRevisionContentSubtitle)
                        .foregroundStyle(QuickRevisionPalette.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Text("Loading revision notes...")
                    .font(AppTypography.quickRevisionContentSubtitle)
                    .foregroundStyle(QuickRevisionPalette.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    var statusSection: some View {
        if viewModel.isLoading && viewModel.content == nil {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading revision notes...")
                    .font(.footnote)
                    .foregroundStyle(QuickRevisionPalette.muted)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Loading revision notes.")
            .accessibilityFocused($focusedElement, equals: .status)
        } else if !viewModel.errorMessage.isEmpty && viewModel.content == nil {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.errorMessage)
                    .font(.footnote)
                    .foregroundStyle(SubjectsPalette.resultIncorrect)

                Button("Retry") {
                    Task {
                        await loadTopic()
                    }
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(QuickRevisionPalette.brand)
            }
            .accessibilityElement(children: .contain)
            .accessibilityFocused($focusedElement, equals: .status)
        }
    }

    @ViewBuilder
    var sectionsContent: some View {
        if let content = viewModel.content {
            if content.sections.isEmpty {
                Text(content.emptyStateMessage)
                    .font(.footnote)
                    .foregroundStyle(QuickRevisionPalette.muted)
            } else {
                VStack(alignment: .leading, spacing: 28) {
                    ForEach(content.sections) { section in
                        VStack(alignment: .leading, spacing: 16) {
                            sectionLabel(section.labelText)
                            QuickRevisionSectionCard(section: section)
                        }
                    }
                }
            }
        }
    }

    func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(AppTypography.quickRevisionSectionLabel)
            .tracking(2.0)
            .foregroundStyle(QuickRevisionPalette.sectionLabel)
            .accessibilityHeader()
    }

    func loadTopic() async {
        let didLoad = await viewModel.load(topic: topic)

        if viewModel.requiresSignOut {
            session.signOut()
        } else if didLoad {
            refreshCenter.didRecordStudyActivity()
        }
    }
}

private struct QuickRevisionSectionCard: View {
    let section: QuickRevisionTopicDetailContent.Section

    var body: some View {
        switch section.style {
        case .definition:
            alignedCard(
                titleFont: AppTypography.quickRevisionDefinitionTitle,
                titleColor: QuickRevisionPalette.brand,
                bodyFont: AppTypography.quickRevisionCardBody,
                bodyColor: QuickRevisionPalette.muted,
                background: AppColors.cardBackground,
                title: section.title,
                body: section.content,
                verticalPadding: 22
            )
        case .formula:
            VStack(spacing: 18) {
                Text(section.title.uppercased())
                    .font(AppTypography.quickRevisionFormulaLabel)
                    .tracking(1.2)
                    .foregroundStyle(QuickRevisionPalette.brand)

                Text(section.content)
                    .font(AppTypography.quickRevisionFormulaExpression)
                    .foregroundStyle(QuickRevisionPalette.ink)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            .frame(maxWidth: .infinity)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(section.title)
            .accessibilityValue(section.content)
        case .principle:
            alignedCard(
                titleFont: AppTypography.quickRevisionLawTitle,
                titleColor: QuickRevisionPalette.ink,
                bodyFont: AppTypography.quickRevisionCardBody,
                bodyColor: QuickRevisionPalette.muted,
                background: AppColors.cardBackground,
                title: section.title,
                body: section.content,
                verticalPadding: 26
            )
        case .summary:
            VStack(alignment: .leading, spacing: 22) {
                Text(section.title)
                    .font(AppTypography.quickRevisionLawTitle)
                    .foregroundStyle(QuickRevisionPalette.ink)

                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(QuickRevisionPalette.brand)
                        .padding(.top, 2)
                        .accessibilityHidden(true)

                    Text(section.content)
                        .font(AppTypography.quickRevisionSummaryBody)
                        .foregroundStyle(QuickRevisionPalette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 28)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(QuickRevisionPalette.summaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(section.title)
            .accessibilityValue(section.content)
        case .generic:
            alignedCard(
                titleFont: AppTypography.quickRevisionLawTitle,
                titleColor: QuickRevisionPalette.ink,
                bodyFont: AppTypography.quickRevisionCardBody,
                bodyColor: QuickRevisionPalette.muted,
                background: AppColors.cardBackground,
                title: section.title,
                body: section.content,
                verticalPadding: 24
            )
        }
    }

    func alignedCard(
        titleFont: Font,
        titleColor: Color,
        bodyFont: Font,
        bodyColor: Color,
        background: Color,
        title: String,
        body: String,
        verticalPadding: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(titleFont)
                .foregroundStyle(titleColor)

            Text(body)
                .font(bodyFont)
                .foregroundStyle(bodyColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, verticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(body)
    }
}
