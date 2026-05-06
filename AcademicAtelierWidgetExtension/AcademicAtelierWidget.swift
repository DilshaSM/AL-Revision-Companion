import SwiftUI
import WidgetKit

@main
struct AcademicAtelierWidget: Widget {
    private let kind = "AcademicAtelierWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetProvider()) { entry in
            WidgetRootView(entry: entry)
        }
        .configurationDisplayName("Academic Atelier")
        .description("See your current study, today’s focus, and weekly goal.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
