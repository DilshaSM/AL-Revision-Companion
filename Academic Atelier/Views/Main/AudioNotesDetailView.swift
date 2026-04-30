import SwiftUI

struct AudioNotesDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var session: SessionViewModel
    @EnvironmentObject private var refreshCenter: AppRefreshCenter

    private let note: AudioNotesTopicSelectionContent.Note

    @StateObject private var viewModel = AudioNotesDetailViewModel()
    @StateObject private var playbackController = AudioPlaybackController()

    @State private var scrubProgress: Double?
    @State private var listeningStartedAt: Date?
    @State private var pendingListenedSeconds: TimeInterval = 0
    @State private var lastSavedPositionSeconds = 0
    @State private var hasConfiguredPlayer = false
    @State private var didSaveCompletion = false
    @AccessibilityFocusState private var focusedElement: FocusTarget?

    private enum FocusTarget: Hashable {
        case title
        case status
    }

    init(note: AudioNotesTopicSelectionContent.Note) {
        self.note = note
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    statusSection
                    playerCard
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 110)
            }
        }
        .background(QuickRevisionPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .task(id: note.id) {
            await loadContent()
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
        .onChange(of: playbackController.isPlaying) { oldValue, isPlaying in
            handlePlaybackStateChange(oldValue: oldValue, isPlaying: isPlaying)
            guard hasConfiguredPlayer else { return }
            Task { @MainActor in
                AccessibilitySupport.announce(isPlaying ? "Playback started." : "Playback paused.")
            }
        }
        .onChange(of: playbackController.completionToken) { _, _ in
            guard hasConfiguredPlayer, playbackController.currentTime >= playbackController.duration else { return }
            Task { @MainActor in
                AccessibilitySupport.announce("Audio note finished.")
            }

            Task {
                await persistProgressIfNeeded(forceSavePosition: true, ended: true)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase != .active else { return }
            playbackController.pause()
            Task {
                await persistProgressIfNeeded(forceSavePosition: true, ended: false)
            }
        }
        .onDisappear {
            playbackController.pause()
            Task {
                await persistProgressIfNeeded(forceSavePosition: true, ended: false)
            }
        }
    }
}

private extension AudioNotesDetailView {
    var topBar: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(AudioNotesDetailPalette.topBarTint)
        }
        .frame(height: 128)
        .overlay(alignment: .leading) {
            HStack(spacing: 16) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(QuickRevisionPalette.brand)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Go back")
                .accessibilityHint("Return to the audio notes list.")

                VStack(alignment: .leading, spacing: 0) {
                    Text(viewModel.content?.topBarLabel ?? "AUDIO NOTES")
                        .font(AppTypography.audioNotesDetailTopBarLabel)
                        .tracking(1.0)
                        .foregroundStyle(QuickRevisionPalette.brand)

                    Text(viewModel.content?.topBarTitle ?? note.subjectName)
                        .font(AppTypography.audioNotesDetailTopBarTitle)
                        .foregroundStyle(QuickRevisionPalette.ink)
                        .padding(.top, 1)
                        .accessibilityHeader()
                        .accessibilityFocused($focusedElement, equals: .title)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 44)
            .padding(.bottom, 44)
        }
    }

    @ViewBuilder
    var statusSection: some View {
        if viewModel.isLoading && viewModel.content == nil {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading audio note...")
                    .font(.footnote)
                    .foregroundStyle(QuickRevisionPalette.muted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Loading audio note.")
            .accessibilityFocused($focusedElement, equals: .status)
        } else if !viewModel.errorMessage.isEmpty && viewModel.content == nil {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.errorMessage)
                    .font(.footnote)
                    .foregroundStyle(SubjectsPalette.resultIncorrect)

                Button("Retry") {
                    Task {
                        await loadContent()
                    }
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(QuickRevisionPalette.brand)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .contain)
            .accessibilityFocused($focusedElement, equals: .status)
        } else if !viewModel.errorMessage.isEmpty {
            Text(viewModel.errorMessage)
                .font(.footnote)
                .foregroundStyle(SubjectsPalette.resultIncorrect)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityFocused($focusedElement, equals: .status)
        } else if viewModel.isSavingProgress {
            Text("Saving listening progress...")
                .font(.footnote)
                .foregroundStyle(QuickRevisionPalette.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityFocused($focusedElement, equals: .status)
        }
    }

    var playerCard: some View {
        let content = viewModel.content

        return VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 0) {
                Text(content?.lessonTitle ?? note.title)
                    .font(AppTypography.audioNotesDetailLessonTitle)
                    .tracking(-0.6)
                    .foregroundStyle(QuickRevisionPalette.ink)

                Text(content?.summary ?? (note.description ?? "Listen to a concise revision summary for this topic."))
                    .font(AppTypography.audioNotesDetailLessonBody)
                    .foregroundStyle(QuickRevisionPalette.muted)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 8)
            }

            waveformSection
                .padding(.top, 8)

            progressSection

            if let content, !playbackController.isAudioAvailable {
                Text(content.audioUnavailableMessage)
                    .font(.footnote)
                    .foregroundStyle(SubjectsPalette.resultIncorrect)
                    .accessibilityFocused($focusedElement, equals: .status)
            }

            playbackControls
                .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .overlay(alignment: .topTrailing) {
            DecorativeOverlay()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: AudioNotesDetailPalette.cardShadow, radius: 24, x: 0, y: 4)
        .accessibilityElement(children: .contain)
    }

    var waveformSection: some View {
        TimelineView(.animation(minimumInterval: 0.067, paused: !playbackController.isPlaying)) { timeline in
            HStack(alignment: .center, spacing: 0) {
                ForEach(Array((viewModel.content?.waveformBars ?? []).enumerated()), id: \.element.id) { index, bar in
                    Capsule(style: .continuous)
                        .fill(color(for: bar.tone))
                        .frame(width: 6, height: animatedHeight(for: bar, index: index, time: timeline.date.timeIntervalSinceReferenceDate))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .frame(height: 96, alignment: .center)
        .accessibilityHidden(true)
    }

    var progressSection: some View {
        VStack(spacing: 8) {
            GeometryReader { proxy in
                Capsule(style: .continuous)
                    .fill(AudioNotesDetailPalette.progressTrack)
                    .overlay(alignment: .leading) {
                        let clampedProgress = displayedProgress
                        let fillWidth = max(proxy.size.width * clampedProgress, clampedProgress > 0 ? 12 : 0)

                        ZStack(alignment: .trailing) {
                            Capsule(style: .continuous)
                                .fill(QuickRevisionPalette.brand)

                            Circle()
                                .fill(QuickRevisionPalette.brand)
                                .frame(width: 12, height: 12)
                                .shadow(color: QuickRevisionPalette.brand.opacity(0.5), radius: 8, x: 0, y: 0)
                                .offset(x: 3)
                        }
                        .frame(width: fillWidth)
                    }
                    .contentShape(Rectangle())
                    .gesture(scrubGesture(trackWidth: proxy.size.width))
            }
            .frame(height: 6)

            HStack {
                Text(formatTime(displayedElapsedTime))
                    .font(AppTypography.audioNotesDetailTimeLabel)
                    .tracking(1.1)
                    .foregroundStyle(QuickRevisionPalette.muted)

                Spacer()

                Text(formatTime(playbackController.duration))
                    .font(AppTypography.audioNotesDetailTimeLabel)
                    .tracking(1.1)
                    .foregroundStyle(QuickRevisionPalette.muted)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Playback position")
        .accessibilityValue("\(formatAccessibilityTime(displayedElapsedTime)) elapsed of \(formatAccessibilityTime(playbackController.duration)).")
        .accessibilityHint("Adjust to scrub through the audio note.")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                playbackController.seek(by: 10)
            case .decrement:
                playbackController.seek(by: -10)
            @unknown default:
                break
            }
        }
    }

    var playbackControls: some View {
        HStack {
            Text(viewModel.content?.playbackSpeedLabel ?? "1x")
                .font(AppTypography.audioNotesDetailSpeedLabel)
                .foregroundStyle(QuickRevisionPalette.muted)
                .frame(minWidth: 48, alignment: .leading)
                .accessibilityLabel("Playback speed")
                .accessibilityValue(viewModel.content?.playbackSpeedLabel ?? "1x")

            Spacer(minLength: 20)

            HStack(spacing: 32) {
                playbackIconButton(systemName: "gobackward.10", disabled: !playbackController.isAudioAvailable) {
                    playbackController.seek(by: -10)
                }
                Button {
                    playbackController.togglePlayPause()
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AudioNotesDetailPalette.playButtonStart, AudioNotesDetailPalette.playButtonEnd],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 64)
                            .shadow(color: AudioNotesDetailPalette.playButtonShadow, radius: 15, x: 0, y: 10)

                        Image(systemName: playbackController.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 27, weight: .bold))
                            .foregroundStyle(.white)
                            .offset(x: playbackController.isPlaying ? 0 : 2)
                    }
                }
                .buttonStyle(.plain)
                .disabled(!playbackController.isAudioAvailable)
                .accessibilityLabel(playbackController.isPlaying ? "Pause audio" : "Play audio")
                .accessibilityHint("Toggle playback.")
                playbackIconButton(systemName: "goforward.10", disabled: !playbackController.isAudioAvailable) {
                    playbackController.seek(by: 10)
                }
            }

            Spacer(minLength: 20)

            playbackIconButton(systemName: "list.bullet", disabled: true) {
            }
            .accessibilityHidden(true)
        }
    }

    var displayedProgress: Double {
        scrubProgress ?? playbackController.progress
    }

    var displayedElapsedTime: Double {
        (scrubProgress ?? playbackController.progress) * playbackController.duration
    }

    func playbackIconButton(systemName: String, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(disabled ? QuickRevisionPalette.muted.opacity(0.4) : QuickRevisionPalette.muted)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .accessibilityLabel(accessibilityLabel(for: systemName))
        .accessibilityHint(accessibilityHint(for: systemName))
    }

    func color(for tone: AudioNotesDetailContent.WaveformBar.Tone) -> Color {
        switch tone {
        case .faint:
            return Color(uiColor: .init(red: 241.0 / 255.0, green: 245.0 / 255.0, blue: 249.0 / 255.0, alpha: 1))
        case .pale:
            return Color(uiColor: .init(red: 226.0 / 255.0, green: 232.0 / 255.0, blue: 240.0 / 255.0, alpha: 1))
        case .soft:
            return Color(uiColor: .init(red: 219.0 / 255.0, green: 234.0 / 255.0, blue: 254.0 / 255.0, alpha: 1))
        case .medium:
            return Color(uiColor: .init(red: 191.0 / 255.0, green: 219.0 / 255.0, blue: 254.0 / 255.0, alpha: 1))
        case .muted:
            return Color(uiColor: .init(red: 203.0 / 255.0, green: 213.0 / 255.0, blue: 225.0 / 255.0, alpha: 1))
        case .accentSoft:
            return Color(uiColor: .init(red: 147.0 / 255.0, green: 197.0 / 255.0, blue: 253.0 / 255.0, alpha: 1))
        case .accent:
            return Color(uiColor: .init(red: 59.0 / 255.0, green: 130.0 / 255.0, blue: 246.0 / 255.0, alpha: 1))
        case .accentDark:
            return Color(uiColor: .init(red: 29.0 / 255.0, green: 78.0 / 255.0, blue: 216.0 / 255.0, alpha: 1))
        }
    }

    func animatedHeight(for bar: AudioNotesDetailContent.WaveformBar, index: Int, time: TimeInterval) -> Double {
        guard playbackController.isPlaying else { return bar.height }

        let normalizedBase = max(bar.height / 96.0, 0.2)
        let phase = time * (4.2 + Double(index % 4) * 0.45) + Double(index) * 0.9
        let pulse = (sin(phase) + sin(phase * 0.63)) * 0.25 + 0.5
        let amplitude = 0.35 + normalizedBase * 0.35
        let animatedScale = max(0.38, min(1.0, 0.45 + pulse * amplitude))

        return max(18, bar.height * animatedScale)
    }

    func scrubGesture(trackWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                scrubProgress = progress(for: value.location.x, trackWidth: trackWidth)
            }
            .onEnded { value in
                let progress = progress(for: value.location.x, trackWidth: trackWidth)
                scrubProgress = nil
                playbackController.seek(toProgress: progress)
            }
    }

    func progress(for locationX: CGFloat, trackWidth: CGFloat) -> Double {
        let effectiveWidth = max(trackWidth, 1)
        return min(max(Double(locationX / effectiveWidth), 0), 1)
    }

    func formatTime(_ seconds: Double) -> String {
        let totalSeconds = max(Int(seconds.rounded(.down)), 0)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    func formatAccessibilityTime(_ seconds: Double) -> String {
        let totalSeconds = max(Int(seconds.rounded(.down)), 0)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60

        if minutes == 0 {
            return "\(remainingSeconds) seconds"
        }

        if remainingSeconds == 0 {
            return minutes == 1 ? "1 minute" : "\(minutes) minutes"
        }

        let minuteText = minutes == 1 ? "1 minute" : "\(minutes) minutes"
        let secondText = remainingSeconds == 1 ? "1 second" : "\(remainingSeconds) seconds"
        return "\(minuteText) \(secondText)"
    }

    func accessibilityLabel(for systemName: String) -> String {
        switch systemName {
        case "gobackward.10":
            return "Rewind 10 seconds"
        case "goforward.10":
            return "Forward 10 seconds"
        case "list.bullet":
            return "Audio note details"
        default:
            return "Audio control"
        }
    }

    func accessibilityHint(for systemName: String) -> String {
        switch systemName {
        case "gobackward.10":
            return "Move playback back by ten seconds."
        case "goforward.10":
            return "Move playback forward by ten seconds."
        case "list.bullet":
            return "Additional details are unavailable here."
        default:
            return ""
        }
    }

    func loadContent() async {
        await viewModel.load(note: note)

        if viewModel.requiresSignOut {
            session.signOut()
            return
        }

        guard let content = viewModel.content else { return }
        playbackController.configure(
            sourceURL: content.audioURL,
            initialElapsed: Double(content.elapsedSeconds),
            initialDuration: Double(content.totalSeconds),
            playbackRate: Float(content.playbackSpeed)
        )
        lastSavedPositionSeconds = content.elapsedSeconds
        listeningStartedAt = nil
        pendingListenedSeconds = 0
        hasConfiguredPlayer = true
        didSaveCompletion = false
    }

    func handlePlaybackStateChange(oldValue: Bool, isPlaying: Bool) {
        guard hasConfiguredPlayer else { return }

        if isPlaying {
            if listeningStartedAt == nil {
                listeningStartedAt = Date()
            }
            return
        }

        guard oldValue else { return }
        accumulateListeningTime()

        let reachedEnd = playbackController.duration > 0 && playbackController.currentTime >= playbackController.duration - 0.5
        guard !reachedEnd else { return }

        Task {
            await persistProgressIfNeeded(forceSavePosition: true, ended: false)
        }
    }

    func accumulateListeningTime() {
        guard let startedAt = listeningStartedAt else { return }
        pendingListenedSeconds += max(Date().timeIntervalSince(startedAt), 0)
        listeningStartedAt = nil
    }

    func persistProgressIfNeeded(forceSavePosition: Bool, ended: Bool) async {
        guard hasConfiguredPlayer, let content = viewModel.content else { return }
        guard !(ended && didSaveCompletion) else { return }

        accumulateListeningTime()

        let positionSeconds = max(Int(playbackController.currentTime.rounded(.down)), 0)
        let listenedSeconds = max(Int(pendingListenedSeconds.rounded()), 0)
        let positionChanged = abs(positionSeconds - lastSavedPositionSeconds) >= 5
        let shouldCreateStudySession = ended || listenedSeconds >= 30
        let shouldSend = ended || shouldCreateStudySession || (forceSavePosition && positionChanged)

        guard shouldSend else { return }

        let durationMinutes = shouldCreateStudySession ? max(Int(ceil(Double(max(listenedSeconds, ended ? 1 : 0)) / 60.0)), 1) : 0
        let didSave = await viewModel.saveProgress(
            noteID: content.id,
            lastPositionSeconds: ended ? content.totalSeconds : positionSeconds,
            playbackSpeed: content.playbackSpeed,
            durationMinutes: durationMinutes,
            ended: ended
        )

        if viewModel.requiresSignOut {
            session.signOut()
            return
        }

        guard didSave else { return }

        if ended || durationMinutes > 0 {
            refreshCenter.didRecordStudyActivity()
        }

        pendingListenedSeconds = 0
        lastSavedPositionSeconds = ended ? 0 : positionSeconds
        didSaveCompletion = ended
    }
}

private struct DecorativeOverlay: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.6))
                .blur(radius: 30)
                .frame(width: 170, height: 170)
                .offset(x: 46, y: -40)

            Circle()
                .stroke(Color.white.opacity(0.14), lineWidth: 2)
                .frame(width: 80, height: 80)
                .offset(x: 28, y: 8)

            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 2)
                .frame(width: 110, height: 110)
                .offset(x: 14, y: 34)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private enum AudioNotesDetailPalette {
    static let topBarTint = Color(uiColor: .init(red: 248.0 / 255.0, green: 250.0 / 255.0, blue: 252.0 / 255.0, alpha: 0.8))
    static let progressTrack = Color(uiColor: .init(red: 232.0 / 255.0, green: 232.0 / 255.0, blue: 237.0 / 255.0, alpha: 1))
    static let playButtonStart = Color(uiColor: .init(red: 0.0 / 255.0, green: 88.0 / 255.0, blue: 188.0 / 255.0, alpha: 1))
    static let playButtonEnd = Color(uiColor: .init(red: 0.0 / 255.0, green: 112.0 / 255.0, blue: 235.0 / 255.0, alpha: 1))
    static let playButtonShadow = Color(uiColor: .init(red: 59.0 / 255.0, green: 130.0 / 255.0, blue: 246.0 / 255.0, alpha: 0.20))
    static let cardShadow = Color.black.opacity(0.04)
}
