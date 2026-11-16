import SwiftUI

/// A circle with the initials of `name`.
struct ProfileInitials: View {
    let name: String
    var size: CGFloat = 32

    private var initials: String {
        name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined().uppercased()
    }

    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(.tint, in: .circle)
    }
}

#Preview {
    ProfileInitials(name: "Normal Paulk")
        .padding()
}
