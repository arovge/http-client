# http-client

An ergonomic wrapper around Foundation's URLSession

Feature roadmap:

- [ ] Multi part file upload
- [ ] Cooperative task cancellation
- [ ] Add custom headers
- [ ] JWT refresh logic

Project roadmap:

- [ ] CI (build/test/fmt)
- [ ] Tests (using [swift-testing](https://github.com/apple/swift-testing))
  - [ ] Unit
  - [ ] Integration/E2E
- [ ] Typed throws (pending Swift 6.0)
- [ ] Complete conurrency checking
- [ ] Use [swift-foundation](https://github.com/apple/swift-foundation) when URLSession is available in it

#### Build

```
swift build
```

#### Test

```
swift test
```

#### Using it in your project

Add this to your `Package.swift`:

```
dependencies: [
    .package(
        url: "https://github.com/arovge/http-client.git",
        branch: "main"
    )
]
```

Then add it to the target you'd like to use it in:

```
.product(name: "HTTPClient", package: "HTTPClient")
```
