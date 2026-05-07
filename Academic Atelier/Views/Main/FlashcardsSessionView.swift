import SwiftData
import SwiftUI

struct FlashcardsSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var session: SessionViewModel
    @EnvironmentObject private var refreshCenter: AppRefreshCenter

    @StateObject private var viewModel: FlashcardsSessionViewModel
    @AccessibilityFocusState private var focusedElement: FocusTarget?

    private enum FocusTarget: Hashable {
        case title
        case status
        case card
        case completion
    }

    init(content: FlashcardsSessionContent) {
        _viewModel = StateObject(wrappedValue: FlashcardsSessionViewModel(content: content))
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            VStack(spacing: 0) {
                progressSection
                    .padding(.top, 22)
                    .padding(.horizontal, 24)

                statusSection
                    .padding(.top, 12)
                    .padding(.horizontal, 24)

                Spacer(minLength: 20)

                flashcardSection
                    .padding(.horizontal, 24)

                Spacer(minLength: 20)

                remainingBadge

                Spacer(minLength: 20)

                bottomActions
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
        .background(QuickRevisionPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
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
        .onChange(of: viewModel.currentIndex) { _, newValue in
            guard !viewModel.isCompleted else { return }
            focusedElement = .card
            Task { @MainActor in
                AccessibilitySupport.announce("Card \(newValue + 1) of \(viewModel.totalCards).")
            }
        }
        .onChange(of: viewModel.isRevealed) { _, isRevealed in
            guard isRevealed, let currentCard = viewModel.currentCard else { return }
            focusedElement = .card
            Task { @MainActor in
                AccessibilitySupport.announce("Answer revealed. \(currentCard.backText)")
            }
        }
        .onChange(of: viewModel.isCompleted) { _, isCompleted in
            guard isCompleted else { return }
            focusedElement = .completion
            Task { @MainActor in
                AccessibilitySupport.announce("Flashcard session complete. Known this \(viewModel.knownCount). Review again \(viewModel.reviewAgainCount).")
            }
        }
    }
}

private extension FlashcardsSessionView {
    var topBar: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(QuickRevisionPalette.topBarTint)
        }
        .frame(height: 96)
        .overlay {
            HStack(spacing: 18) {
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

                Text("FLASHCARDS • \(viewModel.content.topicTitle.uppercased())")
                    .font(AppTypography.flashcardsSessionTopBarTitle)
                    .tracking(2.0)
                    .foregroundStyle(QuickRevisionPalette.sectionLabel)
                    .lineLimit(1)
                    .accessibilityHeader()
                    .accessibilityFocused($focusedElement, equals: .title)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 48)
            .padding(.bottom, 16)
        }
    }

    var progressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("SESSION PROGRESS")
                    .font(AppTypography.flashcardsSessionProgressLabel)
                    .tracking(2.0)
                    .foregroundStyle(QuickRevisionPalette.sectionLabel)

                Spacer(minLength: 12)

                Text(progressText)
                    .font(AppTypography.flashcardsSessionProgressValue)
                    .foregroundStyle(QuickRevisionPalette.ink)
            }

            GeometryReader { proxy in
                Capsule(style: .continuous)
                    .fill(FlashcardsSessionPalette.trackBackground)
                    .overlay(alignment: .leading) {
                        Capsule(style: .continuous)
                            .fill(QuickRevisionPalette.brand)
                            .frame(width: proxy.size.width * viewModel.progressValue)
                    }
            }
            .frame(height: 8)
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Session progress")
        .accessibilityValue(progressText)
    }

    @ViewBuilder
    var statusSection: some View {
        if !viewModel.errorMessage.isEmpty {
            Text(viewModel.errorMessage)
                .font(.footnote)
                .foregroundStyle(SubjectsPalette.resultIncorrect)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityFocused($focusedElement, equals: .status)
        } else if viewModel.isSubmitting {
            Text("Saving response...")
                .font(.footnote)
                .foregroundStyle(QuickRevisionPalette.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityFocused($focusedElement, equals: .status)
        }
    }

    @ViewBuilder
    var flashcardSection: some View {
        if viewModel.isCompleted {
            completionCard
        } else if let currentCard = viewModel.currentCard {
            activeCard(currentCard)
        } else {
            emptyCard
        }
    }

    func activeCard(_ currentCard: FlashcardsSessionContent.Card) -> some View {
        VStack(alignment: .center, spacing: 22) {
            VStack(spacing: 10) {
                Text(currentCard.frontLabel)
                    .font(AppTypography.flashcardsSessionCardEyebrow)
                    .tracking(3.2)
                    .foregroundStyle(FlashcardsSessionPalette.cardEyebrow)

                Capsule(style: .continuous)
                    .fill(FlashcardsSessionPalette.cardEyebrow.opacity(0.35))
                    .frame(width: 36, height: 4)
                    .accessibilityHidden(true)

                Text(currentCard.frontText)
                    .font(AppTypography.flashcardsSessionFrontText)
                    .foregroundStyle(QuickRevisionPalette.ink)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.85)
                    .lineLimit(4)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(currentCard.frontLabel)
            .accessibilityValue(currentCard.frontText)
            .accessibilityFocused($focusedElement, equals: .card)

            if viewModel.isRevealed {
                Text(currentCard.backText)
                    .font(AppTypography.flashcardsSessionBackText)
                    .foregroundStyle(QuickRevisionPalette.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 18)
                    .accessibilityLabel("Answer. \(currentCard.backText)")
            } else {
                VStack(spacing: 14) {
                    HStack(spacing: 10) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(FlashcardsSessionPalette.hintIcon)
                            .accessibilityHidden(true)

                        Text(currentCard.hintText)
                            .font(AppTypography.flashcardsSessionHint)
                            .foregroundStyle(FlashcardsSessionPalette.hintText)
                            .multilineTextAlignment(.center)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Hint")
                    .accessibilityValue(currentCard.hintText)

                    Button {
                        viewModel.revealAnswer()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "eye")
                                .font(.system(size: 18, weight: .medium))
                                .accessibilityHidden(true)

                            Text("TAP TO REVEAL")
                                .font(AppTypography.flashcardsSessionRevealButton)
                                .tracking(1.2)
                        }
                        .foregroundStyle(QuickRevisionPalette.brand)
                        .padding(.horizontal, 24)
                        .frame(height: 60)
                        .background(AppColors.cardBackground)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(FlashcardsSessionPalette.revealBorder, lineWidth: 1.5)
                        )
                        .clipShape(Capsule(style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Reveal answer")
                    .accessibilityHint("Show the answer for this flashcard.")
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 420)
        .padding(.horizontal, 22)
        .padding(.vertical, 32)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: FlashcardsSessionPalette.cardShadow, radius: 16, x: 0, y: 10)
        .accessibilityElement(children: .contain)
    }

    var completionCard: some View {
        VStack(alignment: .center, spacing: 24) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(QuickRevisionPalette.brand)
                .accessibilityHidden(true)

            Text("Session Complete")
                .font(AppTypography.flashcardsSessionFrontText)
                .foregroundStyle(QuickRevisionPalette.ink)

            Text(viewModel.content.completionMessage)
                .font(AppTypography.flashcardsSessionBackText)
                .foregroundStyle(QuickRevisionPalette.muted)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                statPill(title: "KNOW THIS", value: "\(viewModel.knownCount)")
                statPill(title: "REVIEW AGAIN", value: "\(viewModel.reviewAgainCount)")
            }
        }
        .frame(maxWidth: .infinity, minHeight: 420)
        .padding(.horizontal, 22)
        .padding(.vertical, 32)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: FlashcardsSessionPalette.cardShadow, radius: 16, x: 0, y: 10)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Session complete")
        .accessibilityValue("\(viewModel.content.completionMessage) Know this \(viewModel.knownCount). Review again \(viewModel.reviewAgainCount).")
        .accessibilityFocused($focusedElement, equals: .completion)
    }

    var emptyCard: some View {
        VStack(spacing: 16) {
            Text("No flashcards available yet.")
                .font(AppTypography.flashcardsSessionBackText)
                .foregroundStyle(QuickRevisionPalette.muted)
        }
        .frame(maxWidth: .infinity, minHeight: 420)
        .padding(.horizontal, 22)
        .padding(.vertical, 32)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    func statPill(title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(AppTypography.flashcardsSessionFrontText)
                .foregroundStyle(QuickRevisionPalette.ink)

            Text(title)
                .font(AppTypography.flashcardsSessionRemainingBadge)
                .tracking(1.2)
                .foregroundStyle(QuickRevisionPalette.sectionLabel)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(FlashcardsSessionPalette.remainingBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }

    var remainingBadge: some View {
        Text(remainingText)
            .font(AppTypography.flashcardsSessionRemainingBadge)
            .tracking(2.0)
            .foregroundStyle(QuickRevisionPalette.sectionLabel)
        .padding(.horizontal, 20)
        .frame(height: 40)
        .background(FlashcardsSessionPalette.remainingBackground)
        .clipShape(Capsule(style: .continuous))
        .accessibilityLabel("Cards remaining")
        .accessibilityValue(remainingText)
    }

    @ViewBuilder
    var bottomActions: some View {
        if viewModel.isCompleted {
            SessionActionButton(
                title: "DONE",
                iconName: "checkmark",
                style: .primary
            ) {
                dismiss()
            }
        } else {
            HStack(spacing: 14) {
                SessionActionButton(
                    title: "REVIEW AGAIN",
                    iconName: "arrow.counterclockwise",
                    style: .secondary
                ) {
                    Task {
                        let didComplete = await viewModel.respondCurrentCard(as: .reviewAgain)
                        handleResponseCompletion(didComplete, responseTitle: "Review again")
                    }
                }

                SessionActionButton(
                    title: "KNOW THIS",
                    iconName: "checkmark",
                    style: .primary
                ) {
                    Task {
                        let didComplete = await viewModel.respondCurrentCard(as: .knowThis)
                        handleResponseCompletion(didComplete, responseTitle: "Know this")
                    }
                }
            }
            .disabled(viewModel.isSubmitting || viewModel.currentCard == nil)
        }
    }

    var progressText: String {
        guard viewModel.totalCards > 0 else { return "No cards" }
        if viewModel.isCompleted {
            return "Complete"
        }
        return "Card \(viewModel.displayedCardNumber.formatted(.number.precision(.integerLength(2)))) of \(viewModel.totalCards)"
    }

    var remainingText: String {
        if viewModel.isCompleted {
            return "SESSION RECORDED"
        }
        return "\(viewModel.cardsRemaining) CARDS REMAINING"
    }

    func handleResponseCompletion(_ didComplete: Bool, responseTitle: String) {
        if viewModel.requiresSignOut {
            session.signOut()
        } else if didComplete {
            try? LocalPersistenceService(context: modelContext).saveStudyActivity(
                activityType: "flashcards",
                subjectId: viewModel.content.subjectId,
                subjectName: viewModel.content.subjectName,
                topicId: viewModel.content.topicId,
                topicTitle: viewModel.content.topicTitle,
                durationMinutes: max(viewModel.totalCards, 1)
            )
            refreshCenter.didRecordStudyActivity()
        } else {
            Task { @MainActor in
                AccessibilitySupport.announce("\(responseTitle) selected. \(progressText)")
            }
        }
    }
}

private struct SessionActionButton: View {
    enum Style {
        case primary
        case secondary
    }

    let title: String
    let iconName: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .medium))
                    .accessibilityHidden(true)

                Text(title)
                    .font(AppTypography.flashcardsSessionActionButton)
                    .tracking(1.0)
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: shadowColor, radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title.capitalized)
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return QuickRevisionPalette.sectionLabel
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return QuickRevisionPalette.brand
        case .secondary:
            return FlashcardsSessionPalette.secondaryButton
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary:
            return QuickRevisionPalette.brand.opacity(0.22)
        case .secondary:
            return .clear
        }
    }
}

private enum FlashcardsSessionPalette {
    static let trackBackground = Color(uiColor: .init(red: 217.0 / 255.0, green: 228.0 / 255.0, blue: 255.0 / 255.0, alpha: 1))
    static let cardEyebrow = Color(uiColor: .init(red: 157.0 / 255.0, green: 193.0 / 255.0, blue: 245.0 / 255.0, alpha: 1))
    static let hintIcon = Color(uiColor: .init(red: 180.0 / 255.0, green: 184.0 / 255.0, blue: 194.0 / 255.0, alpha: 1))
    static let hintText = Color(uiColor: .init(red: 180.0 / 255.0, green: 184.0 / 255.0, blue: 194.0 / 255.0, alpha: 1))
    static let revealBorder = Color(uiColor: .init(red: 218.0 / 255.0, green: 231.0 / 255.0, blue: 255.0 / 255.0, alpha: 1))
    static let cardShadow = Color(uiColor: .init(red: 3.0 / 255.0, green: 83.0 / 255.0, blue: 188.0 / 255.0, alpha: 0.10))
    static let remainingBackground = Color(uiColor: .init(red: 240.0 / 255.0, green: 243.0 / 255.0, blue: 250.0 / 255.0, alpha: 1))
    static let secondaryButton = Color(uiColor: .init(red: 240.0 / 255.0, green: 243.0 / 255.0, blue: 250.0 / 255.0, alpha: 1))
}
