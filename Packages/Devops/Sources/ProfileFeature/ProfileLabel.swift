import DevopsClient
import SwiftUI

/// The user's avatar and name, for the sidebar.
public struct ProfileLabel: View {
    let person: Person

    public init(person: Person) {
        self.person = person
    }

    public var body: some View {
        Label {
            Text(person.displayName ?? "Profile")
        } icon: {
            ProfileInitials(name: person.displayName ?? "?", size: 22)
        }
    }
}

#Preview {
    List {
        ProfileLabel(person: Person(id: "1", displayName: "Normal Paulk"))
    }
    .listStyle(.sidebar)
    .frame(width: 240, height: 100)
}
