import AuthClient
import DevopsAPI
import DevopsClient
import DevopsClientLive

extension DevopsClient {
    /// The live client; every request gets its credential from `auth`.
    static func live(auth: AuthClient) -> DevopsClient {
        let api = DevopsAPI(middlewares: [
            .logging(),
            .auth(credential: { .personalAccessToken(try await auth.requirePersonalAccessToken()) }),
        ])
        return .live(api: api)
    }
}
