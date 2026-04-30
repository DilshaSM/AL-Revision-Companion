import SwiftUI

struct RecallToolsView: View {
    @Environment(\.dismiss) private var dismiss
    @AccessibilityFocusState private var focusedElement: FocusTarget?

    private let content: RecallToolsContent
    private let actions: RecallToolsViewActions

    private enum FocusTarget: Hashable {
        case title
    }

    init(content: RecallToolsContent = .live, actions: RecallToolsViewActions = .init()) {
        self.content = content
        self.actions = actions
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 40) {
                    headerSection
                    supportToolsSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(QuickRevisionPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            focusedElement = .title
        }
    }
}

private extension RecallToolsView {
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

                Text("Recall Tools")
                    .font(AppTypography.recallToolsTopBarTitle)
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
        VStack(alignment: .leading, spacing: 20) {
            Text("REVISION SUPPORT")
                .font(AppTypography.recallToolsEyebrow)
                .tracking(2.0)
                .foregroundStyle(QuickRevisionPalette.brand)
                .accessibilityHeader()

            VStack(alignment: .leading, spacing: 18) {
                Text(content.title)
                    .font(AppTypography.recallToolsTitle)
                    .tracking(-1.1)
                    .foregroundStyle(QuickRevisionPalette.ink)

                Text(content.subtitle)
                    .font(AppTypography.recallToolsSubtitle)
                    .foregroundStyle(QuickRevisionPalette.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    var supportToolsSection: some View {
        VStack(spacing: 20) {
            RecallSupportCard(
                iconName: "rectangle.on.rectangle",
                accent: .blue,
                title: "Flashcards",
                description: "Review definitions, formulas, and key concepts one card at a time.",
                metadata: "QUICK RECALL • ACTIVE REVIEW",
                action: actions.onTapFlashcards
            )

            RecallSupportCard(
                iconName: "headphones",
                accent: .orange,
                title: "Audio Notes",
                description: "Listen to concise topic summaries for revision on the go.",
                metadata: "HANDS-FREE • LISTEN & REVISE",
                action: actions.onTapAudioNotes
            )
        }
    }
}

struct RecallToolsViewActions {
    var onTapFlashcards: () -> Void = {}
    var onTapAudioNotes: () -> Void = {}
}

private struct RecallSupportCard: View {
    let iconName: String
    let accent: Accent
    let title: String
    let description: String
    let metadata: String
    let action: () -> Void

    enum Accent {
        case blue
        case orange
    }

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(backgroundColor)
                        .frame(width: 84, height: 84)

                    Image(systemName: iconName)
                        .font(.system(size: 34, weight: .medium))
                        .foregroundStyle(accentColor)
                        .accessibilityHidden(true)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 14) {
                    Text(title)
                        .font(AppTypography.recallToolsCardTitle)
                        .foregroundStyle(QuickRevisionPalette.ink)

                    Text(description)
                        .font(AppTypography.recallToolsCardBody)
                        .foregroundStyle(QuickRevisionPalette.muted)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(metadata)
                        .font(AppTypography.recallToolsMetadata)
                        .foregroundStyle(QuickRevisionPalette.sectionLabel.opacity(0.75))
                        .tracking(0.3)
                }

                Spacer(minLength: 12)

                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(QuickRevisionPalette.chevron.opacity(0.5))
                    .padding(.top, 8)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue("\(description) \(metadata)")
        .accessibilityHint("Open \(title).")
    }

    private var accentColor: Color {
        switch accent {
        case .blue:
            return QuickRevisionPalette.brand
        case .orange:
            return RecallToolsPalette.orange
        }
    }

    private var backgroundColor: Color {
        switch accent {
        case .blue:
            return QuickRevisionPalette.iconBackground
        case .orange:
            return RecallToolsPalette.orangeTint
        }
    }
}

private enum RecallToolsPalette {
    static let orange = Color(uiColor: .init(red: 180.0 / 255.0, green: 87.0 / 255.0, blue: 14.0 / 255.0, alpha: 1))
    static let orangeTint = Color(uiColor: .init(red: 243.0 / 255.0, green: 233.0 / 255.0, blue: 225.0 / 255.0, alpha: 1))
}
