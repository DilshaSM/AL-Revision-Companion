import Foundation

struct ProfileContent {
    struct IdentityItem: Identifiable, Hashable {
        enum Kind: Hashable {
            case subjectStream
            case registrationNumber
        }

        let id: Kind
        let title: String
        let detail: String
    }

    let title: String
    let fullName: String
    let streamTitle: String
    let academicSectionTitle: String
    let identityItems: [IdentityItem]
    let signOutTitle: String

    static func build(user: User?) -> Self {
        let fullName = user?.fullName ?? "Student"
        let selectedStream = user?.selectedStream
        let hasSelectedStream = user?.streamId != nil

        return Self(
            title: "Profile",
            fullName: fullName,
            streamTitle: selectedStream?.profileDisplayTitle ?? (hasSelectedStream ? "Selected Stream" : "Pending Stream Selection"),
            academicSectionTitle: "Academic Identity",
            identityItems: [
                .init(
                    id: .subjectStream,
                    title: "Subject Stream",
                    detail: selectedStream?.subjectSummary ?? (hasSelectedStream ? "Stream synced from your account." : "Complete onboarding to choose your academic stream.")
                ),
                .init(
                    id: .registrationNumber,
                    title: "Registration Number",
                    detail: user?.registrationNumber ?? "Not assigned yet"
                )
            ],
            signOutTitle: "Sign Out of A/L Revision Companion"
        )
    }
}

struct ProfileSettingsContent {
    struct PreferenceItem: Identifiable, Hashable {
        enum Kind: Hashable {
            case notifications
            case biometricAuthentication
        }

        let id: Kind
        let title: String
        let subtitle: String
    }

    let title: String
    let sectionTitle: String
    let preferences: [PreferenceItem]

    static let placeholder = Self(
        title: "Settings",
        sectionTitle: "Preferences & Security",
        preferences: [
            .init(
                id: .notifications,
                title: "Push Notifications",
                subtitle: "Daily reminders & quiz alerts"
            ),
            .init(
                id: .biometricAuthentication,
                title: "Biometric Authentication",
                subtitle: "Face ID for secure reports"
            )
        ]
    )
}
