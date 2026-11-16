/// Response bodies modelled on the samples in the Microsoft Learn REST reference (API 7.x).
/// The build fixture is composed from the documented `Build` definition (Learn has no in-progress sample).
enum Fixtures {
    /// Two pull requests: a fully populated one (7-digit date, reviewers with votes) and a sparse one with
    /// unknown enum values and an unknown extra field.
    static let pullRequests = #"""
    {
      "count": 2,
      "value": [
        {
          "repository": {
            "id": "3411ebc1-d5aa-464f-9615-0b527bc66719",
            "name": "2016_10_31",
            "webUrl": "https://dev.azure.com/fabrikam/2016_10_31/_git/2016_10_31",
            "project": { "id": "a7573007-bbb3-4341-b726-0c4148a07853", "name": "2016_10_31", "state": "unchanged" }
          },
          "pullRequestId": 22,
          "codeReviewId": 22,
          "status": "active",
          "createdBy": {
            "id": "d6245f20-2af8-44f4-9451-8107cb2767db",
            "displayName": "Normal Paulk",
            "uniqueName": "fabrikamfiber16@hotmail.com",
            "imageUrl": "https://dev.azure.com/fabrikam/_api/_common/identityImage?id=d6245f20"
          },
          "creationDate": "2016-11-01T16:30:31.6655471Z",
          "title": "A new feature",
          "description": "Adding a new feature",
          "sourceRefName": "refs/heads/npaulk/my_work",
          "targetRefName": "refs/heads/new_feature",
          "mergeStatus": "succeeded",
          "reviewers": [
            {
              "reviewerUrl": "https://dev.azure.com/fabrikam/_apis/git/repositories/3411ebc1/pullRequests/22/reviewers/d6245f20",
              "vote": 10,
              "isRequired": true,
              "id": "d6245f20-2af8-44f4-9451-8107cb2767db",
              "displayName": "Normal Paulk",
              "uniqueName": "fabrikamfiber16@hotmail.com"
            },
            {
              "vote": 0,
              "id": "98d08d98-a075-46e7-a81e-21bc6f12cae7",
              "displayName": "[2016_10_31]\\2016_10_31 Team",
              "isContainer": true
            }
          ],
          "url": "https://dev.azure.com/fabrikam/_apis/git/repositories/3411ebc1/pullRequests/22",
          "supportsIterations": true
        },
        {
          "pullRequestId": 21,
          "status": "someFutureStatus",
          "mergeStatus": "brandNew",
          "isDraft": true,
          "creationDate": "2016-11-01T16:30:23.8410158Z",
          "title": "Added known issues document",
          "unexpectedObject": { "a": 1 }
        }
      ]
    }
    """#

    /// One running build: no `result`, no `finishTime`, 7-digit dates, `_links.web`.
    static let builds = #"""
    {
      "count": 1,
      "value": [
        {
          "_links": {
            "self": { "href": "https://dev.azure.com/fabrikam/a7573007/_apis/build/Builds/5" },
            "web": { "href": "https://dev.azure.com/fabrikam/a7573007/_build/results?buildId=5" }
          },
          "id": 5,
          "buildNumber": "20241101.1",
          "status": "inProgress",
          "reason": "pullRequest",
          "queueTime": "2024-11-01T10:00:00.1234567Z",
          "startTime": "2024-11-01T10:00:05.5Z",
          "sourceBranch": "refs/pull/22/merge",
          "sourceVersion": "b60280bc6e62e2f880f1b63c1e24987664d3bda3",
          "definition": { "id": 7, "name": "CI", "path": "\\", "url": "https://dev.azure.com/fabrikam/a7573007/_apis/build/Definitions/7" },
          "project": { "id": "a7573007-bbb3-4341-b726-0c4148a07853", "name": "Fabrikam" },
          "requestedFor": { "id": "d6245f20-2af8-44f4-9451-8107cb2767db", "displayName": "Normal Paulk" },
          "requestedBy": { "id": "d6245f20-2af8-44f4-9451-8107cb2767db", "displayName": "Normal Paulk" },
          "url": "https://dev.azure.com/fabrikam/a7573007/_apis/build/Builds/5",
          "queueOptions": "none"
        }
      ]
    }
    """#

    static let projects = #"""
    {
      "count": 2,
      "value": [
        {
          "id": "eb6e4656-77fc-42a1-9181-4c6d8e9da5d1",
          "name": "Fabrikam-Fiber-TFVC",
          "description": "Team Foundation Version Control projects",
          "url": "https://dev.azure.com/fabrikam-fiber-inc/_apis/projects/eb6e4656",
          "state": "wellFormed",
          "revision": 11,
          "visibility": "private",
          "lastUpdateTime": "2024-05-01T10:00:00.123Z"
        },
        { "id": "6ce954b1-ce1f-45d1-b94d-e6bf2464ba2c", "name": "Fabrikam-Fiber-Git" }
      ]
    }
    """#

    static let connectionData = #"""
    {
      "authenticatedUser": {
        "id": "d6245f20-2af8-44f4-9451-8107cb2767db",
        "providerDisplayName": "Normal Paulk",
        "isActive": true
      },
      "instanceId": "ab1b6bf2-d5a4-4f1c-b1c1-0d0ef5f5c0aa"
    }
    """#

    /// A running pipeline: one finished stage, a stage with a running job and its task, and an unknown record type.
    static let timeline = #"""
    {
      "id": "a1b2c3d4-0000-0000-0000-000000000001",
      "records": [
        { "id": "stage-1", "parentId": null, "type": "Stage", "name": "Build", "order": 1,
          "state": "completed", "result": "succeeded",
          "startTime": "2024-11-01T10:00:05.5Z", "finishTime": "2024-11-01T10:03:00.1234567Z" },
        { "id": "phase-1", "parentId": "stage-1", "type": "Phase", "name": "Build", "order": 1,
          "state": "completed", "result": "succeeded" },
        { "id": "job-1", "parentId": "phase-1", "type": "Job", "name": "Compile", "order": 1,
          "state": "inProgress", "result": null, "startTime": "2024-11-01T10:00:06Z", "finishTime": null },
        { "id": "task-1", "parentId": "job-1", "type": "Task", "name": "Run tests", "order": 2,
          "state": "pending", "result": null },
        { "id": "check-1", "parentId": "stage-1", "type": "Checkpoint", "name": "Approval", "order": 3,
          "state": "completed", "result": "succeeded" }
      ]
    }
    """#
}
