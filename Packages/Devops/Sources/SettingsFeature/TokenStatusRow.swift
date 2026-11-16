import SwiftUI

struct TokenStatusRow: View {
    let hasToken: Bool

    var body: some View {
        LabeledContent("Status") {
            if hasToken {
                Label("Token saved in Keychain", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            } else {
                Label("No token", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }
        }
    }
}

#Preview {
    Form {
        TokenStatusRow(hasToken: true)
        TokenStatusRow(hasToken: false)
    }
    .formStyle(.grouped)
}
