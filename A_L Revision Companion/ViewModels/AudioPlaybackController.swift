import AVFoundation
import Foundation
import UIKit

@MainActor
final class AudioPlaybackController: ObservableObject {
    @Published private(set) var currentTime: Double
    @Published private(set) var duration: Double
    @Published private(set) var isPlaying = false
    @Published private(set) var isAudioAvailable = false
    @Published private(set) var isPreparingAudio = false
    @Published private(set) var audioErrorMessage: String?
    @Published private(set) var completionToken = UUID()

    private(set) var playbackRate: Float
    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private var playbackEndObserver: NSObjectProtocol?
    private var playerItemStatusObservation: NSKeyValueObservation?

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

        playerItemStatusObservation?.invalidate()
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

        do {
            try Self.activatePlaybackSession()
        } catch {
            handlePlaybackFailure(error, fallbackMessage: "Unable to start audio playback.")
            return
        }

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
        isAudioAvailable = false
        isPreparingAudio = sourceURL != nil
        audioErrorMessage = nil

        if let sourceURL {
            configurePlayer(with: sourceURL)
        }
    }

    private func configurePlayer(with url: URL) {
        let asset = AVURLAsset(url: url, options: [AVURLAssetHTTPUserAgentKey: Self.httpUserAgent])
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        self.player = player

        playerItemStatusObservation = item.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            Task { @MainActor [weak self] in
                guard let self else { return }

                switch item.status {
                case .readyToPlay:
                    self.isPreparingAudio = false
                    self.isAudioAvailable = true
                    self.audioErrorMessage = nil
                case .failed:
                    self.handlePlaybackFailure(item.error, fallbackMessage: "This audio file could not be loaded.")
                case .unknown:
                    self.isPreparingAudio = true
                @unknown default:
                    break
                }
            }
        }

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

        playerItemStatusObservation?.invalidate()
        timeObserverToken = nil
        playbackEndObserver = nil
        playerItemStatusObservation = nil
        player = nil
        isPreparingAudio = false
        audioErrorMessage = nil
        isAudioAvailable = false
    }

    private func handlePlaybackFailure(_ error: Error?, fallbackMessage: String) {
        pause()
        isPreparingAudio = false
        isAudioAvailable = false

        if let nsError = error as NSError? {
            let message = nsError.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            audioErrorMessage = message.isEmpty ? fallbackMessage : message
            return
        }

        audioErrorMessage = fallbackMessage
    }

    private static func activatePlaybackSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .spokenAudio, options: [])
        try session.setActive(true)
    }

    private static var httpUserAgent: String {
        let version = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
        return "Mozilla/5.0 (iPhone; CPU iPhone OS \(version) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(UIDevice.current.systemVersion) Mobile/15E148 Safari/604.1"
    }
}
