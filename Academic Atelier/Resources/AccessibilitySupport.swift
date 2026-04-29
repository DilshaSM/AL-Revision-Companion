import SwiftUI
import UIKit

enum AccessibilitySupport {
    @MainActor
    static func announce(_ message: String) {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        UIAccessibility.post(notification: .announcement, argument: trimmed)
    }

    @MainActor
    static func focusScreenChange(on argument: Any? = nil) {
        UIAccessibility.post(notification: .screenChanged, argument: argument)
    }
}

extension View {
    func accessibilityHeader() -> some View {
        accessibilityAddTraits(.isHeader)
    }
}
