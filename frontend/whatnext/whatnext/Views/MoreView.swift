import SwiftUI
import Firebase
import GoogleSignIn

struct MoreView: View {
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("userID") var storedUserID: String = ""
    @State private var showingLogoutAlert = false
    @State private var selection: String?

    var settings: [SettingsSection] = [
        .init(name: "Preferences", imageName: "person.crop.circle", color: .primary),
        .init(name: "Notifications", imageName: "bell.circle", color: .primary),
        .init(name: "Location", imageName: "location.circle", color: .primary),
        .init(name: "Privacy", imageName: "hand.raised.circle", color: .primary),
        .init(name: "Logout", imageName: "arrow.right.circle", color: .primary)
    ]
    
    var feedbacks: [FeedbackSection] = [
        .init(name: "Overall Experience", imageName: "hand.thumbsup.circle", color: .primary),
        .init(name: "Recommendation Accuracy", imageName: "target", color: .primary),
        .init(name: "Suggestions", imageName: "lightbulb.circle", color: .primary)
    ]
    
    var terms: [TermsAndConditionsSection] = [
        .init(name: "Acceptance of Terms", imageName: "doc.circle", color: .primary),
        .init(name: "Privacy Policy", imageName: "lock.circle", color: .primary),
        .init(name: "User Conduct", imageName: "figure.walk.circle", color: .primary)
    ]

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                settingsSection
                feedbackSection
                termsAndConditionsSection
            }
            .listStyle(.sidebar)
            .navigationTitle("More")
            .alert("Confirm Logout", isPresented: $showingLogoutAlert) {
                Button("Logout", role: .destructive) { logout() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to log out?")
            }
        } detail: {
            detailViewForSelection(selection)
        }
    }
    
    @ViewBuilder
    private var settingsSection: some View {
        Section("Settings") {
            ForEach(settings) { setting in
                if setting.name == "Logout" {
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: setting.imageName)
                            Text(setting.name)
                        }
                        .foregroundColor(setting.color)
                    }
                } else {
                    NavigationLink(value: setting.name) {
                        HStack {
                            Image(systemName: setting.imageName)
                            Text(setting.name)
                        }
                        .foregroundColor(setting.color)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var feedbackSection: some View {
        Section("Feedback") {
            ForEach(feedbacks) { feedback in
                NavigationLink(value: feedback.name) {
                    HStack {
                        Image(systemName: feedback.imageName)
                        Text(feedback.name)
                    }
                    .foregroundColor(feedback.color)
                }
            }
        }
    }
    
    @ViewBuilder
    private var termsAndConditionsSection: some View {
        Section("Terms and Conditions") {
            ForEach(terms) { term in
                NavigationLink(value: term.name) {
                    HStack {
                        Image(systemName: term.imageName)
                        Text(term.name)
                    }
                    .foregroundColor(term.color)
                }
            }
        }
    }

    @ViewBuilder
    private func detailViewForSelection(_ selection: String?) -> some View {
            if let selection = selection {
                switch selection {
                case "Preferences":
                    ActivityView()
                default:
                    DetailedView(title: " \(selection)")
                }
        }
    }

    private func logout() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            withAnimation {
                logStatus = false
                storedUserID = ""
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

// Assuming your Section structs remain unchanged


struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
    }
}

struct SettingsSection: Identifiable {
    var id = UUID()
    let name: String
    let imageName: String
    let color: Color
}

struct FeedbackSection: Identifiable {
    var id = UUID()
    let name: String
    let imageName: String
    let color: Color
}

struct TermsAndConditionsSection: Identifiable {
    
    var id = UUID()
    let name: String
    let imageName: String
    let color:Color
    
    
}
struct DetailedView: View {
    let title: String

    var body: some View {
        Text("Content for \(title)")
            .navigationTitle(title) // Set the title explicitly here
    }
}
