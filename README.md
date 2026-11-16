# Devops-monitor

A macOS app (macOS 26, Swift 6, no third-party dependencies) that keeps an eye on Azure DevOps (cloud) for you: your pull requests and your running pipelines, without keeping a browser tab open.

See `AGENTS.md` for the architecture rules and code conventions.

## What it does

- **Dashboard**: a summary of what needs your attention, your open pull requests, pull requests waiting for your review, pipelines running now and recent runs.
- **Pull requests**: the ones you created and the ones assigned to you, with reviewer votes. A context menu lets you vote and set auto-complete.
- **Pipelines**: your running builds, with the stage / job / task timeline of each run.
- **Activity**: a timeline of the last 30 days (builds, pull requests and their system events), derived from the API on demand. Nothing is stored on the device.
- **Menu bar**: a menu bar item with a badge count and a compact popup of pull requests and pipelines; it opens the matching page of the main window.
- **Notifications**: the app polls Azure DevOps every 30 seconds, diffs the result against the previous snapshot and sends a local notification when something changes (for example a pull request completes or a pipeline finishes).
- **Widgets**: pull request and pipeline widgets fed from a snapshot shared through an App Group.
- **Profile and settings**: who you are signed in as, the organization, and the access token.

The access token is kept in the macOS Keychain.

## Getting started

Requirements: Xcode with the macOS 26 SDK, an Apple developer team (for signing), and an Azure DevOps account.

1. Set up local signing (below).
2. Run `scripts/install-hooks.sh` once per clone to enable the pre-commit signing check.
3. Open `Devops-monitor.xcodeproj` and run the `Devops-monitor` scheme.
4. In the app's settings, enter your organization and an Azure DevOps personal access token.

### Personal access token

Create one at `https://dev.azure.com/<organization>/_usersSettings/tokens` with read access to:

- **Code** (pull requests)
- **Build** (pipelines)
- **Profile** (`vso.profile`, used to identify you)

Pull request voting and auto-complete need write access to Code.

## Project layout

```
Devops-monitor.xcodeproj   app target + widget extension
Devops-monitor/            app target: composition root only (entry point, navigation, wiring)
DevopsWidgets/             widget extension (pull requests, pipelines)
Packages/Devops/           everything else: one Swift package, one module per concern
Config/                    signing xcconfig files
scripts/                   pre-commit signing check and hook installer
plans/, research/          design plans and research notes
```

Inside `Packages/Devops`, dependencies are plain structs of closures (the protocol witness pattern), each split into an interface module and a `...Live` implementation:

| Area | Modules |
|---|---|
| Azure DevOps | `DevopsAPI` (REST, DTOs), `DevopsClient` (domain models + interface), `DevopsClientLive` |
| Token | `AuthClient`, `AuthClientLive` (Keychain) |
| Polling | `MonitorClient`, `MonitorClientLive` |
| Notifications | `NotificationClient`, `NotificationClientLive` |
| Widgets | `SnapshotClient`, `SnapshotClientLive` (App Group file), `WidgetFeature` |
| State | `AppStore` (the single `@Observable` `Store`) |
| Derived data | `ActivityTimeline`, `DashboardSummary` |
| Views | one `...Feature` module per screen: Dashboard, Pipelines, PullRequests, Activity, MenuBar, Profile, Settings |

Features depend on `AppStore` and interface modules only. Only the app target imports the `...Live` modules and composes them. More detail in `AGENTS.md` and `Packages/Devops/README.md`.

## Building and testing

- Package: `cd Packages/Devops && swift build && swift test`
- App: build the `Devops-monitor` scheme in Xcode.

Tests cover code we own (pure functions, the `Store` with overridden closures, the API layer); there is no network stubbing.

## Local signing

The app and its widget extension use an App Group (`group.com.lagoonpixel.Devopsmonitor`) and a shared Keychain group, so they must be signed with your own Apple developer team. Your team ID is **never committed**: it lives in a gitignored file.

1. Find your Team ID in Xcode > Settings > Accounts (a 10-character string such as `ABCDE12345`).
2. Create your local config from the template:

   ```sh
   cp Config/Signing.local.xcconfig.example Config/Signing.local.xcconfig
   ```

3. Edit `Config/Signing.local.xcconfig` and replace `YOURTEAMID` with your Team ID:

   ```
   DEVELOPMENT_TEAM = ABCDE12345
   ```

4. Build. Xcode signs automatically with your team.

If you fork the project under a different bundle identifier, the App Group and Keychain group identifiers in the entitlements and in `SnapshotClient.appGroupID` need to change with it.

### How it works

- `Config/Signing.xcconfig` is tracked, has an empty `DEVELOPMENT_TEAM`, and includes `Signing.local.xcconfig` if it exists (`#include?`).
- `*.local.xcconfig` is in `.gitignore`.
- Both the Debug and Release configurations of the project use `Config/Signing.xcconfig`.

### Rules

- **Do not pick a team in Xcode's Signing & Capabilities tab.** Xcode writes it into the project file, which would leak your team ID. Signing comes from the xcconfig only.
- Never commit certificates, keys, provisioning profiles or `.env` files (all gitignored).
- Entitlements must not hard-code a team ID. If one is needed, use the `$(AppIdentifierPrefix)` build variable, which Xcode expands from your local team at build time.

### Pre-commit check

`scripts/check-no-signing.sh` (run by the hook installed in step 2 of Getting started) fails the commit if:

- signing values (`DEVELOPMENT_TEAM`, `CODE_SIGN_IDENTITY`, provisioning profile) appear in the project or shared schemes,
- an entitlements file contains a team identifier,
- your local team ID appears in any tracked or staged file.

If it fires, move the value into `Config/Signing.local.xcconfig` and revert the change in the project file.

### Troubleshooting

- **"Signing requires a development team"**: `Config/Signing.local.xcconfig` is missing or still contains `YOURTEAMID`.
- **Team keeps showing up in `git diff` of the project file**: you selected a team in the Xcode UI. Revert that change to the project file.
