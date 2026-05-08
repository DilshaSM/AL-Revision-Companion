import Foundation

struct APIConfiguration {
    static let defaultBaseURL = URL(string: "https://al-revision-companion-be.onrender.com/api")!

    let baseURL: URL

    init(
        bundle: Bundle = .main,
        processInfo: ProcessInfo = .processInfo
    ) {
        let environmentValue = Self.normalizedString(processInfo.environment["API_BASE_URL"])
        let bundleValue = Self.normalizedString(
            bundle.object(forInfoDictionaryKey: "API_BASE_URL") as? String
        )
        let rawValue = environmentValue
            ?? bundleValue
            ?? Self.defaultBaseURL.absoluteString

        guard let baseURL = Self.makeBaseURL(from: rawValue) else {
            preconditionFailure("Invalid API_BASE_URL value: \(rawValue)")
        }

        self.baseURL = baseURL

#if DEBUG
        let source = environmentValue != nil
            ? "environment"
            : bundleValue != nil
            ? "info-plist"
            : "default"
        print("[API] Base URL:", baseURL.absoluteString, "source:", source)
#endif
    }

    private static func normalizedString(_ value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else {
            return nil
        }

        return value
    }

    private static func makeBaseURL(from rawValue: String) -> URL? {
        guard var components = URLComponents(string: rawValue),
              let scheme = components.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              let host = components.host,
              !host.isEmpty else {
            return nil
        }

        let trimmedPath = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        components.path = trimmedPath.isEmpty ? "" : "/\(trimmedPath)"

        return components.url
    }
}
