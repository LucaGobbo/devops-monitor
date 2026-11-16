import AppStore
import SwiftUI

public struct SettingsView: View {
    @Environment(Store.self) private var store
    @State private var token = ""

    public init() {}

    public var body: some View {
        @Bindable var store = store
        Form {
            Section {
                TokenStatusRow(hasToken: store.hasToken)
                TextField("Organization", text: $store.organization, prompt: Text("e.g. fabrikam"))
                    .onSubmit { Task { await store.refresh() } }
                SecureField("Token", text: $token, prompt: Text("Paste a personal access token"))
                HStack {
                    Spacer()
                    Button("Remove", role: .destructive) { Task { await store.removeToken() } }
                        .disabled(!store.hasToken)
                    Button("Save") {
                        Task { if await store.saveToken(token) { token = "" } }
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                    .disabled(token.isEmpty)
                }
            } header: {
                Text("Azure DevOps")
            } footer: {
                Text("The organization is the name in dev.azure.com/<organization>. Create a personal access token with read access to Code and Build. It is stored in your Keychain.")
            }

            if let errorMessage = store.errorMessage {
                Section {
                    Label(errorMessage, systemImage: "xmark.octagon.fill")
                        .foregroundStyle(.red)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
    }
}

#Preview {
    @Previewable @State var store = Store.previewValue
    SettingsView()
        .environment(store)
        .task { await store.load() }
        .frame(width: 480, height: 420)
}
