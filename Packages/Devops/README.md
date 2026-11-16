# Devops

Azure DevOps (cloud) client for pull requests and pipeline runs. Three modules:

- `DevopsAPI` — the REST API implementation (a plain struct with injected `apiVersion`, middlewares and transport; DTOs). Unit tested.
- `DevopsClient` — the interface for the app: domain models and `DevopsClient`, a struct of closures with `.testValue` / `.previewValue`. Knows nothing about DTOs.
- `DevopsClientLive` — implements `DevopsClient` on top of `DevopsAPI` (DTO → domain mapping).

```swift
import DevopsAPI
import DevopsClient
import DevopsClientLive

let api = DevopsAPI(middlewares: [
    .logging(),                                   // outermost: sees requests before credentials are attached
    .auth(.personalAccessToken(pat)),             // or .auth(.bearer(token)) / .auth(credential: { ... })
])
let client = DevopsClient.live(api: api)

let me = try await client.currentUser()           // cache this in your store; needs the vso.profile scope
let created  = try await client.pullRequests("org", .createdByMe, me)
let assigned = try await client.pullRequests("org", .assignedToMe, me)
let running  = try await client.activeBuilds("org", me)
```

Polling and other business logic are the app's concern.
