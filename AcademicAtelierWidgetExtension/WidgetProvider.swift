import Foundation
import WidgetKit

struct WidgetProvider: TimelineProvider {
    private let cacheService = WidgetCacheService.shared

    func placeholder(in context: Context) -> WidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        let entry = WidgetEntry(
            date: .now,
            summary: cacheService.load() ?? WidgetEntry.placeholder.summary
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let entry = WidgetEntry(date: .now, summary: cacheService.load())
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }
}
