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
        let fullName = user?.fullName ?? "Chamith Gamage"
        let selectedStream = user?.selectedStream

        return Self(
            title: "Profile",
            fullName: fullName,
            streamTitle: selectedStream?.profileDisplayTitle ?? "Physical Science",
            academicSectionTitle: "Academic Identity",
            identityItems: [
                .init(
                    id: .subjectStream,
                    title: "Subject Stream",
                    detail: selectedStream?.subjectSummary ?? "Combined Maths, Physics,\nChemistry"
                ),
                .init(
                    id: .registrationNumber,
                    title: "Registration Number",
                    detail: "AL/2024/09321-S"
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

private extension Stream {
    var profileDisplayTitle: String {
        switch self {
        case .science:
            return "Physical Science"
        case .commerce:
            return "Commerce"
        case .arts:
            return "Arts"
        case .technology:
            return "Technology"
        }
    }

    var subjectSummary: String {
        switch self {
        case .science:
            return "Combined Maths, Physics,\nChemistry"
        case .commerce:
            return "Accounting, Economics,\nBusiness Studies"
        case .arts:
            return "History, Political Science,\nMedia Studies"
        case .technology:
            return "Engineering Tech, Science for Tech,\nICT"
        }
    }
}
