import Foundation

struct ProfileService {
    private let client: APIClient

    init(client: APIClient = APIClient()) {
        self.client = client
    }

    func getProfile() async throws -> CurrentUserPayload {
        try await client.send(
            path: "/users/me",
            method: "GET",
            requiresAuth: true
        )
    }

    func getPreferences() async throws -> PreferencesPayload {
        try await client.send(
            path: "/users/me/preferences",
            method: "GET",
            requiresAuth: true
        )
    }

    func updatePreferences(
        localNotificationsEnabled: Bool? = nil,
        biometricEnabled: Bool? = nil
    ) async throws -> PreferencesPayload {
        try await client.send(
            path: "/users/me/preferences",
            method: "PATCH",
            body: UpdatePreferencesRequest(
                localNotificationsEnabled: localNotificationsEnabled,
                biometricEnabled: biometricEnabled
            ),
            requiresAuth: true
        )
    }
}
