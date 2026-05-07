import SwiftUI

struct StartupSplashView: View {
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                Spacer(minLength: max(proxy.size.height * 0.08, 44))

                VStack(spacing: 12) {
                    Text("Welcome to")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(SplashPalette.brand)
                        .multilineTextAlignment(.center)

                    Text("A/L Revision Companion")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundStyle(SplashPalette.brand)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.75)
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 28)

                Image("SplashIllustration")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: min(proxy.size.width - 80, 292))
                    .clipShape(RoundedRectangle(cornerRadius: 38, style: .continuous))
                    .shadow(color: SplashPalette.brand.opacity(0.08), radius: 24, x: 0, y: 14)
                    .accessibilityHidden(true)

                Spacer(minLength: 28)

                Text("Revise Smarter. Score Higher.")
                    .font(.system(size: 26, weight: .medium, design: .rounded))
                    .foregroundStyle(SplashPalette.subtitle)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Spacer(minLength: 28)

                Text("Get Start")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 68)
                    .background(SplashPalette.button)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: SplashPalette.button.opacity(0.22), radius: 18, x: 0, y: 12)
                    .padding(.horizontal, 28)
                    .accessibilityHidden(true)

                SplashLoadingDots()
                    .padding(.top, 24)

                Spacer(minLength: max(proxy.size.height * 0.1, 48))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SplashPalette.background.ignoresSafeArea())
        }
        .accessibilityElement(children: .contain)
    }
}

private struct SplashLoadingDots: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.1, paused: false)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            HStack(spacing: 18) {
                ForEach(0..<3, id: \.self) { index in
                    let progress = dotProgress(for: time, index: index)

                    Circle()
                        .fill(index == 0 ? SplashPalette.dotMuted : SplashPalette.button)
                        .frame(width: 16, height: 16)
                        .scaleEffect(0.78 + (0.34 * progress))
                        .opacity(0.45 + (0.55 * progress))
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading session")
        .accessibilityValue("Please wait")
    }

    private func dotProgress(for time: TimeInterval, index: Int) -> Double {
        let shifted = time - (Double(index) * 0.18)
        let normalized = (sin(shifted * 3.6 * .pi) + 1) / 2
        return max(0.2, normalized)
    }
}

private enum SplashPalette {
    static let background = Color(red: 0.88, green: 0.93, blue: 0.99)
    static let brand = Color(red: 0.14, green: 0.34, blue: 0.89)
    static let button = Color(red: 0.10, green: 0.47, blue: 0.94)
    static let subtitle = Color(red: 0.48, green: 0.58, blue: 0.67)
    static let dotMuted = Color(red: 0.47, green: 0.72, blue: 0.98)
}
