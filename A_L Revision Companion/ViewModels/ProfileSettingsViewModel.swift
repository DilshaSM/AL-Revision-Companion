import Foundation
import LocalAuthentication
import UserNotifications

@MainActor
final class ProfileSettingsViewModel: ObservableObject {
    @Published private(set) var settings: ProfileSettings
    @Published private(set) var isLoading = false
    @Published private(set) var isSavingNotifications = false
    @Published private(set) var isSavingBiometric = false
    @Published private(set) var errorMessage = ""

    private let notificationScheduler = RevisionNotificationScheduler()
    private let dashboardService = DashboardService()
    private let notificationService: NotificationService

    init(settings: ProfileSettings = .init()) {
        notificationService = .shared
        self.settings = settings
    }

    func applyExternalSettings(_ settings: ProfileSettings) {
        guard !isLoading, !isSavingNotifications, !isSavingBiometric else { return }
        self.settings = settings
    }

    func load(from session: SessionViewModel) async throws {
        isLoading = true
        errorMessage = ""

        defer { isLoading = false }

        let fetchedSettings = try await session.refreshPreferences()
        settings = fetchedSettings

        let authorizationStatus = await notificationAuthorizationStatus()
        if authorizationStatus == .denied, fetchedSettings.areNotificationsEnabled {
            let syncedSettings = try await session.savePreferences(localNotificationsEnabled: false)
            settings = syncedSettings
            errorMessage = "Notifications are denied in iOS Settings, so reminders were disabled in the app."
        }
    }

    func setNotificationsEnabled(
        _ isEnabled: Bool,
        session: SessionViewModel
    ) async throws {
        guard settings.areNotificationsEnabled != isEnabled else { return }

        errorMessage = ""
        let previousSettings = settings
        settings.areNotificationsEnabled = isEnabled
        isSavingNotifications = true

        defer { isSavingNotifications = false }

        do {
            if isEnabled {
                let granted = try await requestNotificationAuthorizationIfNeeded()
                guard granted else {
                    settings = previousSettings
                    errorMessage = "Enable notifications in iOS Settings before turning this preference on."
                    return
                }
            }

            settings = try await session.savePreferences(localNotificationsEnabled: isEnabled)

            if isEnabled {
                let homePayload = try await dashboardService.getHome()
                try await notificationScheduler.rescheduleNotifications(
                    isEnabled: true,
                    homePayload: homePayload
                )
            } else {
                notificationService.cancelRevisionNotifications()
            }
        } catch {
            settings = previousSettings
            throw error
        }
    }

    func setBiometricEnabled(
        _ isEnabled: Bool,
        session: SessionViewModel
    ) async throws {
        guard settings.isFaceIDEnabled != isEnabled else { return }

        errorMessage = ""
        let previousSettings = settings
        settings.isFaceIDEnabled = isEnabled
        isSavingBiometric = true

        defer { isSavingBiometric = false }

        do {
            if isEnabled {
                try await validateBiometricEnrollment()
            }

            settings = try await session.savePreferences(biometricEnabled: isEnabled)
        } catch {
            settings = previousSettings
            throw error
        }
    }

    func setErrorMessage(_ message: String) {
        errorMessage = message
    }

    private func notificationAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationService.notificationSettings()
        return settings.authorizationStatus
    }

    private func requestNotificationAuthorizationIfNeeded() async throws -> Bool {
        try await notificationService.requestAuthorizationIfNeeded()
    }

    private func validateBiometricEnrollment() async throws {
        let context = LAContext()
        var evaluationError: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &evaluationError) else {
            throw DevicePreferenceError(message: evaluationError?.localizedDescription ?? "Biometric authentication is not available on this device.")
        }

        let reason = "Enable biometric authentication for this app."
        do {
            try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
        } catch {
            throw DevicePreferenceError(message: error.localizedDescription)
        }
    }
}

private struct DevicePreferenceError: LocalizedError {
    let message: String

    var errorDescription: String? { message }
}
