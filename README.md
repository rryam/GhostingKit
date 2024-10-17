# GhostingKit: Unofficial Swift SDK for Ghost API 👻

GhostingKit is an unofficial Swift SDK for the Ghost Content API to interact with Ghost blogs, allowing you to fetch posts, pages, tags, and authors detail. I was learning about Phantom Types in Swift when learning about the Ghost Content API, and that is how I came with the name PhantomKit. Then, a week later, I had a thought about how recruiters ghosted me during my internship hunt so I renamed this library to GhostingKit. 

- [Features](#features)
- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager)
- [Usage](#usage)
- [Examples](#examples)
  - [Fetching Posts](#fetching-posts)
  - [Fetching Pages](#fetching-pages)
  - [Fetching Tags](#fetching-tags)
  - [Fetching Authors](#fetching-authors)
  - [Fetching a Specific Post](#fetching-a-specific-post)
  - [Fetching a Specific Page](#fetching-a-specific-page)
- [Contributing](#contributing)
- [License](#license)

## Features

- One line Swift methods for the Ghost Content API using Swift concurrency
- Built for Swift 6.0 and compatible with iOS 16+, macOS 13+, tvOS 16+, watchOS 9+, and visionOS 1+

## Installation

### Swift Package Manager

You can add GhostingKit to your project using Swift Package Manager. Add the following line to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/rryam/GhostingKit.git", from: "0.1.0")
]
```

Or add it directly in Xcode using File > Add Packages and enter the repository URL.

## Usage

Import GhostingKit in your Swift file:

```swift
import GhostingKit
```

Then, create an instance of `GhostingKit` with your Ghost site's admin domain and Content API key:

```swift
let ghostingKit = GhostingKit(
    adminDomain: "your-site.ghost.io",
    apiKey: "your-content-api-key"
)
```

## Examples

### Fetching Posts

To fetch posts from your Ghost blog:

```swift
do {
    let postsResponse = try await ghostingKit.getPosts(limit: 15, page: 1)
    for post in postsResponse.posts {
        print(post.title)
    }
} catch {
    print("Error fetching posts: \(error)")
}
```

### Fetching Pages

To fetch pages from your Ghost site:

```swift
do {
    let pagesResponse = try await ghostingKit.getPages(limit: 10, page: 1)
    for page in pagesResponse.pages {
        print(page.title)
    }
} catch {
    print("Error fetching pages: \(error)")
}
```

### Fetching Tags

To fetch tags from your Ghost blog:

```swift
do {
    let tagsResponse = try await ghostingKit.getTags(limit: 20, include: "count.posts")
    for tag in tagsResponse.tags {
        print("\(tag.name): \(tag.count?.posts ?? 0) posts")
    }
} catch {
    print("Error fetching tags: \(error)")
}
```

### Fetching Authors

To fetch authors from your Ghost blog:

```swift
do {
    let authorsResponse = try await ghostingKit.getAuthors(limit: 5, include: "count.posts")
    for author in authorsResponse.authors {
        print("\(author.name): \(author.count?.posts ?? 0) posts")
    }
} catch {
    print("Error fetching authors: \(error)")
}
```

### Fetching a Specific Post

To fetch a specific post by its ID:

```swift
do {
    let post = try await ghostingKit.getPost(id: "post-id", include: "authors,tags")
    print("Post title: \(post.title)")
    print("Author: \(post.authors?.first?.name ?? "Unknown")")
} catch {
    print("Error fetching post: \(error)")
}
```

### Fetching a Specific Page

To fetch a specific page by its slug:

```swift
do {
    let page = try await ghostingKit.getPageBySlug(slug: "about", include: "authors")
    print("Page title: \(page.title)")
    print("Content: \(page.html)")
} catch {
    print("Error fetching page: \(error)")
}
```

## Contributing

Contributions to GhostingKit are more than welcome! Please feel free to submit a Pull Request.

## License

PhantomKit is available under the MIT license. See the LICENSE file for more info.

Note: Not affiliated with Ghost.
