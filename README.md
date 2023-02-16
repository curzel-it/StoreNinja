# StoreNinja

Imagine you run a simple app, and you want to know:
* What's the latest version of this app available on the store?
* Has this version even been released?
* Is there an update available

This library answers those questions, and does so by "parsing" the AppStore page of your app.

There's limitations to what it can do (one being gradual releases for example) with only the informations coming from the store page, but it still works for small projects.

Supports custom logics for parsing the store page and comparing version numbers.

## Examples
These are taken directly from [this test case](https://github.com/curzel-it/StoreNinja/blob/main/Tests/StoreNinjaTests/StoreNinjaTests.swift).

### Is an update available?
```swift
let checker = StoreNinja.checker(appId: "1575542220")
let updateStatus = await checker.availableUpdateFromCurrentVersion()

switch updateStatus {
case .updateAvailable(let latestVersion): // ...
case .noUpdatesAvailable: // ...
case .unknown(let error): // ...
}
```

### Has this version been released on the store yet?
```swift
let checker = StoreNinja.checker(appId: "1575542220")
let releasedStatus = await checker.isCurrentVersionReleased()

switch releasedStatus {
case .yes(let isLatest): // ...
case .no: // Is this a test? 
case .unknown(let error): // ...
}
```
