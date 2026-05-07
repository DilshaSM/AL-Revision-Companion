import SwiftUI

struct QuickRevisionTopicSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionViewModel
    @StateObject private var viewModel = QuickRevisionTopicSelectionViewModel()
    @AccessibilityFocusState private var focusedElement: FocusTarget?

    private let subject: QuickRevisionSubject
    private let actions: QuickRevisionTopicSelectionActions

    private enum FocusTarget: Hashable {
        case title
        case status
    }

    init(subject: QuickRevisionSubject, actions: QuickRevisionTopicSelectionActions = .init()) {
        self.subject = subject
        self.actions = actions
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    headerSection
                    statusSection
                    topicsSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .background(QuickRevisionPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task(id: subject.id) {
            await load(forceRefresh: false)
        }
        .refreshable {
            await load(forceRefresh: true)
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

private extension QuickRevisionTopicSelectionView {
    var topBar: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(QuickRevisionPalette.topBarTint)
        }
        .frame(height: 96)
        .overlay {
            HStack(spacing: 16) {
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
                .accessibilityHint("Return to the previous screen.")

                Text("Select Topic")
                    .font(AppTypography.quickRevisionTopBarTitle)
                    .tracking(-0.6)
                    .foregroundStyle(QuickRevisionPalette.topBarInk)
                    .accessibilityHeader()
                    .accessibilityFocused($focusedElement, equals: .title)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 48)
            .padding(.bottom, 16)
        }
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(subject.title)
                .font(AppTypography.quickRevisionTopicTitle)
                .tracking(-0.9)
                .foregroundStyle(QuickRevisionPalette.ink)

            Text("Select a topic for quick revision.")
                .font(AppTypography.quickRevisionTopicSubtitle)
                .foregroundStyle(QuickRevisionPalette.muted)
        }
    }

    @ViewBuilder
    var statusSection: some View {
        if viewModel.isLoading && viewModel.topics.isEmpty {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading topics...")
                    .font(.footnote)
                    .foregroundStyle(QuickRevisionPalette.muted)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Loading topics.")
            .accessibilityFocused($focusedElement, equals: .status)
        } else if !viewModel.errorMessage.isEmpty && viewModel.topics.isEmpty {
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
            .accessibilityElement(children: .contain)
            .accessibilityFocused($focusedElement, equals: .status)
        } else if viewModel.isLoading {
            Text("Refreshing topics...")
                .font(.footnote)
                .foregroundStyle(QuickRevisionPalette.muted)
                .accessibilityFocused($focusedElement, equals: .status)
        }
    }

    var topicsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All \(subject.title) Topics".uppercased())
                .font(AppTypography.quickRevisionSectionLabel)
                .tracking(1.2)
                .foregroundStyle(QuickRevisionPalette.sectionLabel)
                .accessibilityHeader()

            if viewModel.topics.isEmpty, let emptyStateMessage = emptyStateMessage {
                Text(emptyStateMessage)
                    .font(.footnote)
                    .foregroundStyle(QuickRevisionPalette.muted)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.topics) { topic in
                        QuickRevisionTopicRow(topic: topic) {
                            actions.onTapTopic(topic)
                        }
                    }
                }
            }
        }
    }

    var emptyStateMessage: String? {
        guard !viewModel.isLoading, viewModel.errorMessage.isEmpty else { return nil }
        return "No quick revision topics available for this subject yet."
    }

    func load(forceRefresh: Bool) async {
        await viewModel.load(subject: subject, forceRefresh: forceRefresh)

        if viewModel.requiresSignOut {
            session.signOut()
        }
    }
}

struct QuickRevisionTopicSelectionActions {
    var onTapTopic: (QuickRevisionTopic) -> Void = { _ in }
}

private struct QuickRevisionTopicRow: View {
    let topic: QuickRevisionTopic
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(QuickRevisionPalette.iconBackground)
                        .frame(width: 48, height: 48)

                    Image(systemName: topic.symbolName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(QuickRevisionPalette.brand)
                        .accessibilityHidden(true)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 0) {
                    Text(topic.title)
                        .font(AppTypography.quickRevisionListTitle)
                        .foregroundStyle(QuickRevisionPalette.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let subtitle = topic.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(AppTypography.quickRevisionTopicRowSubtitle)
                            .foregroundStyle(QuickRevisionPalette.muted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Spacer(minLength: 12)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(QuickRevisionPalette.chevron)
                    .accessibilityHidden(true)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(topic.title)
        .accessibilityValue(topic.subtitle ?? "")
        .accessibilityHint("Open quick revision notes for this topic.")
    }
}
