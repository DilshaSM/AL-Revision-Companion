import AVFoundation
import Foundation

@MainActor
final class AudioPlaybackController: ObservableObject {
    @Published private(set) var currentTime: Double
    @Published private(set) var duration: Double
    @Published private(set) var isPlaying = false

    private let playbackRate: Float
    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private var playbackEndObserver: NSObjectProtocol?
    private var mockTimer: Timer?

    init(sourceURL: URL?, initialElapsed: Double, initialDuration: Double, playbackRate: Float) {
        currentTime = max(initialElapsed, 0)
        duration = max(initialDuration, 1)
        self.playbackRate = playbackRate

        if let sourceURL {
            configurePlayer(with: sourceURL)
        }
    }

    deinit {
        if let timeObserverToken, let player {
            player.removeTimeObserver(timeObserverToken)
        }

        if let playbackEndObserver {
            NotificationCenter.default.removeObserver(playbackEndObserver)
        }

        mockTimer?.invalidate()
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(max(currentTime / duration, 0), 1)
    }

    func togglePlayPause() {
        isPlaying ? pause() : play()
    }

    func play() {
        if let player {
            player.play()
            player.rate = playbackRate
        } else {
            startMockPlayback()
        }

        isPlaying = true
    }

    func pause() {
        player?.pause()
        mockTimer?.invalidate()
        mockTimer = nil
        isPlaying = false
    }

    func seek(by delta: Double) {
        seek(to: currentTime + delta)
    }

    func seek(toProgress progress: Double) {
        seek(to: duration * min(max(progress, 0), 1))
    }

    private func configurePlayer(with url: URL) {
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        self.player = player

        let observerInterval = CMTime(seconds: 0.2, preferredTimescale: 600)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: observerInterval, queue: .main) { [weak self] time in
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

        playbackEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.isPlaying = false
            self.currentTime = self.duration
        }

        seek(to: currentTime)
    }

    private func startMockPlayback() {
        mockTimer?.invalidate()
        mockTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.currentTime = min(self.currentTime + (0.2 * Double(self.playbackRate)), self.duration)

            if self.currentTime >= self.duration {
                self.pause()
            }
        }
    }

    private func seek(to seconds: Double) {
        let clampedTime = min(max(seconds, 0), duration)

        if let player {
            let cmTime = CMTime(seconds: clampedTime, preferredTimescale: 600)
            player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
        }

        currentTime = clampedTime
    }
}
