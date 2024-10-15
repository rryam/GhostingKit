# PhantomKit: Unofficial Swift SDK for Ghost API 👻

PhantomKit is an unofficial Swift SDK for the Ghost Content API to interact with Ghost blogs, allowing you to fetch posts, pages (soon), tags (soon) and authors (soon) detail. I was learning about Phantom Types in Swift when learning about the Ghost Content API, and that is how I came with the name PhantomKit.

## Features

- One line Swift methods for the Ghost Content API using Swift concurrency
- Built for Swift 6.0 and compatible with iOS 16+, macOS 13+, tvOS 16+, watchOS 9+, and visionOS 1+

## Installation

### Swift Package Manager

You can add PhantomKit to your project using Swift Package Manager. Add the following line to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/rryam/PhantomKit.git", from: "0.1.0")
]
```

Or add it directly in Xcode using File > Add Packages and enter the repository URL.

## Usage

Import PhantomKit in your Swift file:

```swift
import PhantomKit
```

Then, create an instance of `PhantomKit` with your Ghost site's admin domain and Content API key:

```swift
let phantomKit = PhantomKit(
    adminDomain: "your-site.ghost.io",
    apiKey: "your-content-api-key"
)
```

### Fetching Posts

To fetch posts from your Ghost blog:

```swift
do {
    let postsResponse = try await phantomKit.getPosts(limit: 15, page: 1)
    for post in postsResponse.posts {
        print(post.title)
    }
} catch {
    print("Error fetching posts: \(error)")
}
```

## Contributing

Contributions to PhantomKit are more than welcome! Please feel free to submit a Pull Request.

## License

PhantomKit is available under the MIT license. See the LICENSE file for more info.

Note: Not affiliated with Ghost.
