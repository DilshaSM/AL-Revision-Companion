import SwiftUI

struct AudioNotesTopicSelectionView: View {
    @Environment(\.dismiss) private var dismiss

    private let content: AudioNotesTopicSelectionContent
    private let actions: AudioNotesTopicSelectionActions

    init(
        content: AudioNotesTopicSelectionContent = .placeholder,
        actions: AudioNotesTopicSelectionActions = .init()
    ) {
        self.content = content
        self.actions = actions
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    availableTopicsSection
                        .padding(.top, 24)
                    recentAudioNotesSection
                        .padding(.top, 50)
                }
                .padding(.horizontal, 24)
                .padding(.top, 26)
                .padding(.bottom, 56)
            }
        }
        .background(QuickRevisionPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

private extension AudioNotesTopicSelectionView {
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

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(content.title)
                .font(AppTypography.audioNotesTopicSelectionTitle)
                .tracking(-0.9)
                .foregroundStyle(QuickRevisionPalette.ink)

            Text(content.subtitle)
                .font(AppTypography.audioNotesTopicSelectionSubtitle)
                .foregroundStyle(QuickRevisionPalette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var availableTopicsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(content.availableTopicsTitle.uppercased())
                .font(AppTypography.audioNotesTopicSelectionSectionLabel)
                .tracking(1.6)
                .foregroundStyle(QuickRevisionPalette.sectionLabel)

            VStack(spacing: 12) {
                ForEach(content.availableTopics) { topic in
                    AudioNotesTopicRow(topic: topic) {
                        actions.onTapTopic(topic)
                    }
                }
            }
        }
    }

    var recentAudioNotesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(content.recentAudioNotesTitle.uppercased())
                .font(AppTypography.audioNotesTopicSelectionSectionLabel)
                .tracking(1.6)
                .foregroundStyle(QuickRevisionPalette.sectionLabel)

            VStack(spacing: 12) {
                ForEach(content.recentAudioNotes) { note in
                    RecentAudioNoteRow(note: note) {
                        actions.onTapRecentAudioNote(note)
                    }
                }
            }
        }
    }
}

struct AudioNotesTopicSelectionActions {
    var onTapTopic: (AudioNotesTopicSelectionContent.Topic) -> Void = { _ in }
    var onTapRecentAudioNote: (AudioNotesTopicSelectionContent.RecentAudioNote) -> Void = { _ in }
}

private struct AudioNotesTopicRow: View {
    let topic: AudioNotesTopicSelectionContent.Topic
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AudioNotesPalette.iconBackground)
                        .frame(width: 48, height: 48)

                    Image(systemName: topic.symbolName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AudioNotesPalette.iconAccent)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(topic.title)
                        .font(AppTypography.audioNotesTopicSelectionRowTitle)
                        .foregroundStyle(QuickRevisionPalette.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(topic.detailText)
                        .font(AppTypography.audioNotesTopicSelectionRowDetail)
                        .foregroundStyle(QuickRevisionPalette.muted)
                        .padding(.top, 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer(minLength: 12)

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(QuickRevisionPalette.chevron)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct RecentAudioNoteRow: View {
    let note: AudioNotesTopicSelectionContent.RecentAudioNote
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AudioNotesPalette.recentIconBackground)
                        .frame(width: 32, height: 32)

                    Image(systemName: note.symbolName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AudioNotesPalette.iconAccent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(note.title)
                        .font(AppTypography.audioNotesTopicSelectionRecentTitle)
                        .foregroundStyle(QuickRevisionPalette.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(note.detailText)
                        .font(AppTypography.audioNotesTopicSelectionRecentDetail)
                        .tracking(0.4)
                        .foregroundStyle(QuickRevisionPalette.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 59, alignment: .leading)
            .background(AudioNotesPalette.recentBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private enum AudioNotesPalette {
    static let iconAccent = QuickRevisionPalette.brand
    static let iconBackground = QuickRevisionPalette.iconBackground
    static let recentBackground = Color(uiColor: .init(red: 243.0 / 255.0, green: 243.0 / 255.0, blue: 248.0 / 255.0, alpha: 1))
    static let recentIconBackground = iconAccent.opacity(0.10)
}
