import SwiftUI
import WidgetKit

@main
struct ALRevisionCompanionWidget: Widget {
    private let kind = "ALRevisionCompanionWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetProvider()) { entry in
            WidgetRootView(entry: entry)
        }
        .configurationDisplayName("A/L Revision Companion")
        .description("See your current study, today’s focus, and weekly goal.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
