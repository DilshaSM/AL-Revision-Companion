import AVFoundation
import Foundation

@MainActor
final class AudioPlaybackController: ObservableObject {
    @Published private(set) var currentTime: Double
    @Published private(set) var duration: Double
    @Published private(set) var isPlaying = false
    @Published private(set) var isAudioAvailable = false
    @Published private(set) var completionToken = UUID()

    private(set) var playbackRate: Float
    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private var playbackEndObserver: NSObjectProtocol?

    init(
        sourceURL: URL? = nil,
        initialElapsed: Double = 0,
        initialDuration: Double = 1,
        playbackRate: Float = 1
    ) {
        currentTime = max(initialElapsed, 0)
        duration = max(initialDuration, 1)
        self.playbackRate = max(playbackRate, 0.5)

        if let sourceURL {
            configurePlayer(with: sourceURL)
            isAudioAvailable = true
        }
    }

    deinit {
        player?.pause()

        if let timeObserverToken, let player {
            player.removeTimeObserver(timeObserverToken)
        }

        if let playbackEndObserver {
            NotificationCenter.default.removeObserver(playbackEndObserver)
        }
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(max(currentTime / duration, 0), 1)
    }

    func togglePlayPause() {
        isPlaying ? pause() : play()
    }

    func play() {
        guard isAudioAvailable, let player else { return }

        player.play()
        player.rate = playbackRate

        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func seek(by delta: Double) {
        seek(to: currentTime + delta)
    }

    func seek(toProgress progress: Double) {
        seek(to: duration * min(max(progress, 0), 1))
    }

    func configure(
        sourceURL: URL?,
        initialElapsed: Double,
        initialDuration: Double,
        playbackRate: Float
    ) {
        teardownPlayer()
        currentTime = max(initialElapsed, 0)
        duration = max(initialDuration, 1)
        self.playbackRate = max(playbackRate, 0.5)
        isPlaying = false
        isAudioAvailable = sourceURL != nil

        if let sourceURL {
            configurePlayer(with: sourceURL)
        }
    }

    private func configurePlayer(with url: URL) {
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        self.player = player

        let observerInterval = CMTime(seconds: 0.2, preferredTimescale: 600)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: observerInterval, queue: .main) { [weak self] time in
            Task { @MainActor [weak self] in
                guard let self else { return }

                let seconds = time.seconds
                if seconds.isFinite {
                    self.currentTime = max(seconds, 0)
                }

                let durationSeconds = item.duration.seconds
                if durationSeconds.isFinite, durationSeconds > 0 {
                    self.duration = durationSeconds
                }

                self.isPlaying = player.timeControlStatus == .playing
            }
        }

        playbackEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isPlaying = false
                self.currentTime = self.duration
                self.completionToken = UUID()
            }
        }

        seek(to: currentTime)
    }

    private func seek(to seconds: Double) {
        let clampedTime = min(max(seconds, 0), duration)

        if let player {
            let cmTime = CMTime(seconds: clampedTime, preferredTimescale: 600)
            player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
        }

        currentTime = clampedTime
    }

    private func teardownPlayer() {
        pause()

        if let timeObserverToken, let player {
            player.removeTimeObserver(timeObserverToken)
        }

        if let playbackEndObserver {
            NotificationCenter.default.removeObserver(playbackEndObserver)
        }

        timeObserverToken = nil
        playbackEndObserver = nil
        player = nil
    }
}
