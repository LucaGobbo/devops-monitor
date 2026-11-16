# AGENTS.md

macOS app that monitors Azure DevOps (cloud): the user's pull requests (created / assigned) and running pipelines.
Swift 6, approachable concurrency, macOS 26. No third-party dependencies.

## Layout

- `Devops-monitor.xcodeproj`, app target `Devops-monitor/`: **composition root only** (app entry, navigation, wiring of live implementations into the `Store`).
- `Packages/Devops`: everything else, one module per concern.

| Module | Role |
|---|---|
| `DevopsAPI` | Azure DevOps REST API: DTOs, request building, transport, middleware (auth, logging), decoding. Plain struct dependency, unit tested. |
| `DevopsClient` | Interface: domain models + `DevopsClient` (struct of closures), `.testValue` / `.previewValue`. Knows nothing about DTOs. |
| `DevopsClientLive` | Implements `DevopsClient` on `DevopsAPI` (DTO -> domain mapping). |
| `AuthClient` / `AuthClientLive` | Interface / keychain implementation for the personal access token. |
| `ActivityTimeline` | `ActivityEvent` values and the pure `ActivityTimeline.events(...)` that derives the activity timeline from builds, pull requests and their system threads. Nothing is stored on the device; `Store.loadActivity()` fetches the last 30 days from the API. |
| `AppStore` | The single `@Observable` `Store`: token state, organization, profile, pipelines, pull requests, `refresh()`. Sits above the features; depends on interface modules only. |
| `SettingsFeature`, `PipelinesFeature`, `PullRequestsFeature`, `ActivityFeature` | One module per feature: its views, reading the `Store` from `@Environment`. |

## Architecture rules

- **Protocol witness pattern** for dependencies: a struct of closures in an interface module, with `testValue` / `previewValue`, and the live implementation in a separate `...Live` module. Use protocols only the way Swift intends, not as interfaces.
- Features depend on `AppStore` and **interface modules only** (`DevopsClient`, `AuthClient`). Only `MyApp` creates the `Store` and injects it with `.environment`. Only the app target imports `...Live` modules and composes them.
- Domain models are exposed to features, never DTOs.
- Business logic (polling, caching `me`, etc.) lives in the `Store`, not in the API layer.
- Keep the API surface small: only operations the app needs; parameters are injected per call, stable values (api-version, base URLs) are constants/properties.

## Code style

- **Every view has a `#Preview`** (use `.previewValue` clients).
- **One type per file**, file named after the type. Exceptions are allowed when types are tiny and inseparable (e.g. a private helper next to its only user).
- **Always extract views into a new `View` type.** Never use computed properties or functions that return views (`var header: some View`, `func row() -> some View`).
- Prefer Swift Testing for tests.
- Surgical changes: touch only what the task needs, match existing style.

## Testing

- Only test code we own, and prefer pure functions. No `URLSession` / `URLProtocol` stubbing, no real network.
- `DevopsAPI` has unit tests (`swift test` in `Packages/Devops`). `DevopsClient`, `DevopsClientLive` and the app target need no unit tests.
- To test the `Store`, override closures on `.previewValue` / `.testValue`.

## Build

- Package: `cd Packages/Devops && swift build && swift test`
- App: build the `Devops-monitor` scheme in Xcode, prefer `XcodeMCP` over `xcodebuild` or `swift build`
- App target build settings: `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, internal-imports-by-default, member-import-visibility (imports must be explicit). Package targets are not MainActor by default; mark UI/model types `@MainActor`.
- Adding a package product to the app: add it under `package-product-members` in `Devops-monitor.xcodeproj/project.xcproj`.

## Signing

- Never put `DEVELOPMENT_TEAM`, `CODE_SIGN_IDENTITY` or provisioning values in `project.xcproj`; Xcode's Signing & Capabilities UI writes them back there, so don't pick a team in it.
- Signing comes from `Config/Signing.xcconfig` (tracked, empty team), which includes the gitignored `Config/Signing.local.xcconfig`. Copy `Signing.local.xcconfig.example` to create it.
- `scripts/check-no-signing.sh` fails if signing values reappear in the project/scheme/entitlements, or if your local team ID shows up in any tracked or staged file. It runs as a pre-commit hook: run `scripts/install-hooks.sh` once per clone to enable it.
- Never commit certificates, keys, provisioning profiles or `.env` files (all gitignored).
