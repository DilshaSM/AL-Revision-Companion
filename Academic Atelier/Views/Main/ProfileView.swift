import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Student") {
                    Text(session.currentUser?.fullName ?? "Student")
                    Text(session.currentUser?.email ?? "No Email")
                    Text(session.currentUser?.selectedStream?.rawValue ?? "No Stream")
                }

                Section("Preferences") {
                    Toggle("Face ID Login", isOn: $viewModel.settings.isFaceIDEnabled)
                    Toggle("Notifications", isOn: $viewModel.settings.areNotificationsEnabled)
                }

                Section {
                    Button("Sign Out", role: .destructive) {
                        session.signOut()
                    }
                }
            }
            .navigationTitle("Profile")
        }
        .onAppear {
            viewModel.settings = session.profileSettings
        }
        .onChange(of: viewModel.settings) { _, newSettings in
            session.updateProfileSettings(newSettings)
        }
    }
}
