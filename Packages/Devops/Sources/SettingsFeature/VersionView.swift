import SwiftUI

/// The app version and build number of `bundle`, like "1.2.3 (1)".
public struct VersionView: View {
    var bundle: Bundle = .main

    public init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    public var body: some View {
        Text(text)
    }

    private var text: String {
        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return "\(version) (\(build))"
    }
}

#Preview {
    VersionView()
        .padding()
}
