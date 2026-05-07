import Foundation
import WidgetKit

struct WidgetCacheService {
    static let shared = WidgetCacheService()

    static let suiteName = "group.com.academicatelier.revision"

    private let cacheKey = "cached_widget_summary"

    private var defaults: UserDefaults? {
        UserDefaults(suiteName: Self.suiteName)
    }

    func save(_ summary: CachedWidgetSummary) {
        guard let data = try? JSONEncoder().encode(summary) else { return }
        defaults?.set(data, forKey: cacheKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    func load() -> CachedWidgetSummary? {
        guard let data = defaults?.data(forKey: cacheKey) else { return nil }
        return try? JSONDecoder().decode(CachedWidgetSummary.self, from: data)
    }

    func clear() {
        defaults?.removeObject(forKey: cacheKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
