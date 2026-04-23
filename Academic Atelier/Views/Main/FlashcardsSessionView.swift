import SwiftUI

struct FlashcardsSessionView: View {
    @Environment(\.dismiss) private var dismiss

    private let content: FlashcardsSessionContent

    @State private var currentIndex = 0
    @State private var isRevealed = false

    init(content: FlashcardsSessionContent) {
        self.content = content
    }

    private var currentCard: FlashcardsSessionContent.Card {
        content.cards[currentIndex]
    }

    private var totalCards: Int {
        content.cards.count
    }

    private var displayedCardNumber: Int {
        min(currentIndex + 1, totalCards)
    }

    private var cardsRemaining: Int {
        max(totalCards - displayedCardNumber, 0)
    }

    private var progressValue: CGFloat {
        guard totalCards > 0 else { return 0 }
        return CGFloat(displayedCardNumber) / CGFloat(totalCards)
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            VStack(spacing: 0) {
                progressSection
                    .padding(.top, 22)
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

                Text("FLASHCARDS • \(content.topicTitle.uppercased())")
                    .font(AppTypography.flashcardsSessionTopBarTitle)
                    .tracking(2.0)
                    .foregroundStyle(QuickRevisionPalette.sectionLabel)
                    .lineLimit(1)

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

                Text("Card \(displayedCardNumber.formatted(.number.precision(.integerLength(2)))) of \(totalCards)")
                    .font(AppTypography.flashcardsSessionProgressValue)
                    .foregroundStyle(QuickRevisionPalette.ink)
            }

            GeometryReader { proxy in
                Capsule(style: .continuous)
                    .fill(FlashcardsSessionPalette.trackBackground)
                    .overlay(alignment: .leading) {
                        Capsule(style: .continuous)
                            .fill(QuickRevisionPalette.brand)
                            .frame(width: proxy.size.width * progressValue)
                    }
            }
            .frame(height: 8)
        }
    }

    var flashcardSection: some View {
        VStack(alignment: .center, spacing: 22) {
            VStack(spacing: 10) {
                Text(currentCard.frontLabel)
                    .font(AppTypography.flashcardsSessionCardEyebrow)
                    .tracking(3.2)
                    .foregroundStyle(FlashcardsSessionPalette.cardEyebrow)

                Capsule(style: .continuous)
                    .fill(FlashcardsSessionPalette.cardEyebrow.opacity(0.35))
                    .frame(width: 36, height: 4)

                Text(currentCard.frontText)
                    .font(AppTypography.flashcardsSessionFrontText)
                    .foregroundStyle(QuickRevisionPalette.ink)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.85)
                    .lineLimit(4)
            }

            if isRevealed {
                Text(currentCard.backText)
                    .font(AppTypography.flashcardsSessionBackText)
                    .foregroundStyle(QuickRevisionPalette.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 18)
            } else {
                VStack(spacing: 14) {
                    HStack(spacing: 10) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(FlashcardsSessionPalette.hintIcon)

                        Text(currentCard.hintText)
                            .font(AppTypography.flashcardsSessionHint)
                            .foregroundStyle(FlashcardsSessionPalette.hintText)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        isRevealed = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "eye")
                                .font(.system(size: 18, weight: .medium))

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
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 420)
        .padding(.horizontal, 22)
        .padding(.vertical, 32)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: FlashcardsSessionPalette.cardShadow, radius: 16, x: 0, y: 10)
    }

    var remainingBadge: some View {
        Text("\(cardsRemaining) CARDS REMAINING")
            .font(AppTypography.flashcardsSessionRemainingBadge)
            .tracking(2.0)
            .foregroundStyle(QuickRevisionPalette.sectionLabel)
            .padding(.horizontal, 20)
            .frame(height: 40)
            .background(FlashcardsSessionPalette.remainingBackground)
            .clipShape(Capsule(style: .continuous))
    }

    var bottomActions: some View {
        HStack(spacing: 14) {
            SessionActionButton(
                title: "REVIEW AGAIN",
                iconName: "arrow.counterclockwise",
                style: .secondary,
                action: advanceToNextCard
            )

            SessionActionButton(
                title: "KNOW THIS",
                iconName: "checkmark",
                style: .primary,
                action: advanceToNextCard
            )
        }
    }

    func advanceToNextCard() {
        guard totalCards > 0 else { return }
        if currentIndex < totalCards - 1 {
            currentIndex += 1
            isRevealed = false
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
