# Releasing

Pushing a tag `vX.Y.Z` runs `.github/workflows/release.yml`, which tests the package, builds the app, signs it with a Developer ID certificate, notarizes it and attaches a stapled `Devops-monitor-X.Y.Z.dmg` (plus a `.sha256`) to a new GitHub Release. Users open the DMG and drag the app to Applications; Gatekeeper does not warn.

```sh
git tag v1.0.0 && git push origin v1.0.0
```

The version comes from the tag (`MARKETING_VERSION`), the build number from the workflow run number. **Actions > Release > Run workflow** does the same build as a dry run: the DMG is attached to the run, nothing is published. Do this once before the first real tag.

## One-time setup

Requires a paid Apple Developer Program account. Everything below is created at developer.apple.com or in App Store Connect; nothing here is committed (see `.gitignore`).

1. **Developer ID Application certificate.** Create it (Certificates > `+` > Developer ID Application), install it in Keychain Access, then export it with its private key as a `.p12` with a password.
2. **Two Developer ID provisioning profiles**, one per bundle ID. The app group and keychain group are restricted entitlements, so a signed build needs a profile that grants them.
   - App IDs `com.lagoonpixel.Devopsmonitor` and `com.lagoonpixel.Devopsmonitor.DevopsWidgets`, both with the **App Groups** capability and the group `group.com.lagoonpixel.Devopsmonitor`.
   - Profiles > `+` > Distribution > **Developer ID** (macOS), one per App ID, using the certificate from step 1.
3. **App Store Connect API key** for notarization (Users and Access > Integrations > Team Keys). Note the Key ID and Issuer ID, and download the `.p8` (only possible once).
4. **Repository secrets** (Settings > Secrets and variables > Actions), e.g. with `gh secret set NAME`:

| Secret | Value |
|---|---|
| `DEVELOPER_ID_CERT_P12_BASE64` | `base64 -i cert.p12` |
| `DEVELOPER_ID_CERT_PASSWORD` | the `.p12` password |
| `APP_PROVISIONING_PROFILE_BASE64` | `base64 -i` of the app's profile |
| `WIDGET_PROVISIONING_PROFILE_BASE64` | `base64 -i` of the widget's profile |
| `NOTARY_API_KEY_P8_BASE64` | `base64 -i AuthKey_XXXX.p8` |
| `NOTARY_API_KEY_ID` | the Key ID |
| `NOTARY_API_ISSUER_ID` | the Issuer ID |

The team ID is read from the profiles, so it is not a secret.

## How signing works here

`AGENTS.md` keeps signing values out of the project. The workflow keeps that rule: it writes an xcconfig to the runner's temp directory and passes it to `xcodebuild archive -xcconfig`. Each target (app, widget) selects its profile through `PROVISIONING_PROFILE_SPECIFIER = $(DM_PROFILE_$(TARGET_NAME:c99extidentifier))`. Nothing signing-related is written to the repo, and `scripts/check-no-signing.sh` keeps passing. The temporary keychain, key and profiles are removed at the end of the job.

## Things to know

- **Runner:** the project file (`project.xcproj`) needs Xcode 27, which GitHub only provides on the `xcode-27` runner label. The workflow pins `DEVELOPER_DIR` to `/Applications/Xcode_27.2.0.app`, the version the image provides and the one the archive step was tested with. If GitHub removes that version or renames the label, update `DEVELOPER_DIR` / `runs-on`.
- **Hardened runtime** is off in the project but forced on in CI (notarization requires it).
- **Notarization failures** print Apple's log in the job output (`scripts/notarize.sh`).
- **DMG** is built with `hdiutil` (app plus an Applications link, no background art) so that no third-party code runs next to the signing keychain. A prettier DMG tool can be added later if wanted.
- Secrets are not exposed to pull requests from forks, and the workflow only triggers on tags or manual runs.
