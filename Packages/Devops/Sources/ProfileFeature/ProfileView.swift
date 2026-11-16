import AppStore
import SwiftUI

public struct ProfileView: View {
    @Environment(Store.self) private var store

    public init() {}

    public var body: some View {
        Form {
            if let profile = store.profile {
                Section {
                    HStack(spacing: 14) {
                        ProfileInitials(name: profile.displayName ?? "?", size: 56)
                        Text(profile.displayName ?? "Unknown user").font(.title2.weight(.semibold))
                    }
                    .padding(.vertical, 4)
                }
                Section {
                    LabeledContent("Organization", value: store.organization)
                    LabeledContent("User id") {
                        Text(profile.id).textSelection(.enabled)
                    }
                }
            } else {
                ContentUnavailableView(
                    "No profile", systemImage: "person.crop.circle",
                    description: Text("Add a token and organization in Settings.")
                )
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Profile")
    }
}

#Preview {
    @Previewable @State var store = Store.previewValue
    ProfileView()
        .environment(store)
        .task { await store.load() }
}
