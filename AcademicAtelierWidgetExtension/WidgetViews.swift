import SwiftUI
import WidgetKit

struct WidgetRootView: View {
    @Environment(\.widgetFamily) private var family

    let entry: WidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(summary: entry.summary)
                .widgetURL(entry.summary?.continueLearningURL ?? URL(string: "academicatelier://home")!)
        case .systemMedium:
            MediumWidgetView(summary: entry.summary)
        default:
            SmallWidgetView(summary: entry.summary)
                .widgetURL(URL(string: "academicatelier://home")!)
        }
    }
}

private struct SmallWidgetView: View {
    let summary: CachedWidgetSummary?

    var body: some View {
        ZStack {
            WidgetTheme.background

            if let continueLearning = summary?.continueLearning {
                VStack(alignment: .leading, spacing: 10) {
                    Text("CURRENT STUDY")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(WidgetTheme.eyebrow)

                    Text(continueLearning.subtitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(WidgetTheme.secondaryText)
                        .lineLimit(1)

                    Text(continueLearning.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(WidgetTheme.primaryText)
                        .lineLimit(3)

                    Spacer(minLength: 0)

                    Text("\(continueLearning.progressPercent)% complete")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(WidgetTheme.secondaryText)

                    ProgressBar(value: Double(continueLearning.progressPercent) / 100.0)
                }
                .padding(16)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("A/L Revision")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(WidgetTheme.primaryText)

                    Text("Open the app to continue studying.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(WidgetTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()
                }
                .padding(16)
            }
        }
        .containerBackground(for: .widget) {
            WidgetTheme.background
        }
    }
}

private struct MediumWidgetView: View {
    let summary: CachedWidgetSummary?

    var body: some View {
        ZStack {
            WidgetTheme.background

            HStack(spacing: 16) {
                Link(destination: summary?.todaysFocusURL ?? URL(string: "academicatelier://home")!) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TODAY’S FOCUS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(WidgetTheme.eyebrow)

                        Text(summary?.todaysFocus?.subtitle ?? "A/L Revision")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(WidgetTheme.secondaryText)
                            .lineLimit(1)

                        Text(summary?.todaysFocus?.title ?? "Open the app for your latest focus recommendation.")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(WidgetTheme.primaryText)
                            .lineLimit(3)

                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 14) {
                    Link(destination: summary?.continueLearningURL ?? URL(string: "academicatelier://home")!) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("CONTINUE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(WidgetTheme.eyebrow)

                            Text(summary?.continueLearning?.title ?? "Open the app to continue learning.")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(WidgetTheme.primaryText)
                                .lineLimit(2)
                        }
                    }
                    .buttonStyle(.plain)

                    Link(destination: summary?.progressURL ?? URL(string: "academicatelier://progress")!) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("WEEKLY GOAL")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(WidgetTheme.eyebrow)

                            Text("\(summary?.revisionProgress.weeklyGoalPercent ?? 0)%")
                                .font(.system(size: 22, weight: .heavy))
                                .foregroundStyle(WidgetTheme.primaryText)

                            Text("\(summary?.revisionProgress.activeDays ?? 0)/7 Days")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(WidgetTheme.secondaryText)
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 0)
                }
                .frame(width: 120, alignment: .topLeading)
            }
            .padding(16)
        }
        .containerBackground(for: .widget) {
            WidgetTheme.background
        }
        .widgetURL(summary?.homeURL ?? URL(string: "academicatelier://home")!)
    }
}

private struct ProgressBar: View {
    let value: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(WidgetTheme.track)

                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(WidgetTheme.fill)
                    .frame(width: max(8, geometry.size.width * max(0, min(value, 1))))
            }
        }
        .frame(height: 8)
    }
}

private enum WidgetTheme {
    static let background = LinearGradient(
        colors: [
            Color(red: 0.95, green: 0.97, blue: 1.0),
            Color(red: 0.89, green: 0.93, blue: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryText = Color(red: 0.11, green: 0.15, blue: 0.25)
    static let secondaryText = Color(red: 0.29, green: 0.38, blue: 0.57)
    static let eyebrow = Color(red: 0.13, green: 0.39, blue: 0.82)
    static let track = Color.white.opacity(0.7)
    static let fill = Color(red: 0.15, green: 0.46, blue: 0.97)
}
