import Foundation

struct APIConfiguration {
    let baseURL: URL

    init(bundle: Bundle = .main) {
        let configuredBaseURL = (bundle.object(forInfoDictionaryKey: "API_BASE_URL") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let fallbackBaseURL = "http://localhost:5001/api"
        let rawValue = configuredBaseURL?.isEmpty == false
            ? configuredBaseURL!
            : fallbackBaseURL

        guard let baseURL = URL(string: rawValue) else {
            preconditionFailure("Invalid API_BASE_URL value: \(rawValue)")
        }

        self.baseURL = baseURL
    }
}
