import SwiftUI

struct ProgressFillBar: View {
    let progress: Double
    let fill: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(ProgressPalette.progressTrack)

                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(fill)
                    .frame(width: max(0, geometry.size.width * progress))
            }
        }
        .frame(height: 4)
        .accessibilityHidden(true)
    }
}
