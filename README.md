# GhostingKit

A modern, type-safe Swift library for interacting with the Ghost Content API. GhostingKit provides a comprehensive set of tools for building Ghost-powered applications with features like caching, retry logic, request cancellation, and more.

## Features

- ✅ **Complete Ghost Content API Coverage**: Posts, pages, authors, tags, tiers, and settings
- ✅ **Type-Safe**: Strongly typed models with proper Swift types (Date, optionals, etc.)
- ✅ **Modern Swift**: Built with async/await, actors, and Swift 5.9+ features
- ✅ **Caching**: Built-in caching with configurable TTL and LRU eviction
- ✅ **Retry Logic**: Configurable exponential backoff for failed requests
- ✅ **Request Cancellation**: Cancel individual requests or all active requests
- ✅ **Pagination**: Helper utilities for paginated content and streaming
- ✅ **Error Handling**: Comprehensive error types with detailed messages
- ✅ **Security**: Secure configuration loading from Bundle, environment, or JSON
- ✅ **SwiftUI Ready**: Complete example app with navigation and detail views

## Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add GhostingKit to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/GhostingKit.git", from: "1.0.0")
]
```

## Quick Start

### Basic Usage

```swift
import GhostingKit

// Initialize with your Ghost site credentials
let ghostingKit = try GhostingKit(
    adminDomain: "your-site.ghost.io",
    apiKey: "your-content-api-key"
)

// Fetch posts
let posts = try await ghostingKit.getPosts(limit: 10)
print("Found \(posts.posts.count) posts")

// Fetch a specific post
let post = try await ghostingKit.getPost(id: "post-id")
print("Post title: \(post.title)")
```

### Secure Configuration

#### From Info.plist

Add these keys to your `Info.plist`:
```xml
<key>GhostAdminDomain</key>
<string>your-site.ghost.io</string>
<key>GhostAPIKey</key>
<string>your-content-api-key</string>
```

```swift
let configuration = try GhostingKitConfiguration.fromBundle()
let ghostingKit = try GhostingKit(configuration: configuration)
```

#### From Environment Variables

```bash
export GHOST_ADMIN_DOMAIN="your-site.ghost.io"
export GHOST_API_KEY="your-content-api-key"
```

```swift
let configuration = try GhostingKitConfiguration.fromEnvironment()
let ghostingKit = try GhostingKit(configuration: configuration)
```

## API Reference

### Posts

```swift
// Get all posts
let posts = try await ghostingKit.getPosts(limit: 15, page: 1)

// Get posts with authors and tags included
let postsWithAuthors = try await ghostingKit.getPosts(
    limit: 10,
    include: "authors,tags"
)

// Filter posts by tag
let swiftPosts = try await ghostingKit.getPosts(
    filter: "tag:swift",
    include: "authors,tags"
)

// Get a specific post
let post = try await ghostingKit.getPost(id: "post-id")
let postBySlug = try await ghostingKit.getPostBySlug(slug: "post-slug")
```

### Authors

```swift
// Get all authors
let authors = try await ghostingKit.getAuthors()

// Get a specific author
let author = try await ghostingKit.getAuthor(id: "author-id")
let authorBySlug = try await ghostingKit.getAuthorBySlug(slug: "author-slug")
```

### Tags

```swift
// Get all tags
let tags = try await ghostingKit.getTags()

// Get public tags only
let publicTags = try await ghostingKit.getTags(filter: "visibility:public")

// Get a specific tag
let tag = try await ghostingKit.getTag(id: "tag-id")
let tagBySlug = try await ghostingKit.getTagBySlug(slug: "tag-slug")
```

### Pages

```swift
// Get all pages
let pages = try await ghostingKit.getPages()

// Get a specific page
let page = try await ghostingKit.getPage(id: "page-id")
let pageBySlug = try await ghostingKit.getPageBySlug(slug: "page-slug")
```

### Settings

```swift
// Get site settings
let settings = try await ghostingKit.getSettings()
print("Site title: \(settings.title)")
print("Site description: \(settings.description)")
```

### Tiers (Membership)

```swift
// Get membership tiers
let tiers = try await ghostingKit.getTiers()

// Get a specific tier
let tier = try await ghostingKit.getTier(id: "tier-id")
```

## Advanced Features

### Caching

```swift
// Configure caching
let cacheConfig = GhostingKitCacheConfiguration(
    ttl: 300,        // 5 minutes
    maxItems: 100,   // Maximum 100 cached items
    isEnabled: true
)

let config = GhostingKitConfiguration(
    adminDomain: "your-site.ghost.io",
    apiKey: "your-api-key",
    cacheConfiguration: cacheConfig
)

let ghostingKit = try GhostingKit(configuration: config)

// Clear cache when needed
await ghostingKit.clearCache()
```

### Retry Logic

```swift
// Configure retry behavior
let retryConfig = GhostingKitRetryConfiguration(
    maxAttempts: 3,
    baseDelay: 1.0,
    useExponentialBackoff: true,
    maxDelay: 60.0,
    retryableStatusCodes: [408, 429, 500, 502, 503, 504]
)

let config = GhostingKitConfiguration(
    adminDomain: "your-site.ghost.io",
    apiKey: "your-api-key",
    retryConfiguration: retryConfig
)
```

### Request Cancellation

```swift
// Cancellable requests
let cancellableRequest = await ghostingKit.getPostsCancellable(limit: 10)

// Cancel the specific request
cancellableRequest.cancel()

// Or cancel all active requests
await ghostingKit.cancelAllRequests()

// Get the result
do {
    let posts = try await cancellableRequest.task.value
    print("Got \(posts.posts.count) posts")
} catch {
    print("Request failed or was cancelled: \(error)")
}
```

### Pagination

```swift
// Use pagination helpers
let posts = try await ghostingKit.getPosts(limit: 10, page: 1)
if let pagination = posts.pagination {
    print("Page \(pagination.currentPage) of \(pagination.totalPages)")
    print("Total posts: \(pagination.totalCount)")
    
    if pagination.hasNextPage {
        let nextPage = try await ghostingKit.getPosts(limit: 10, page: pagination.nextPage!)
    }
}

// Get all posts across multiple pages
let allPosts = try await ghostingKit.getAllPosts(pageSize: 15, maxPages: 5)

// Stream posts for memory efficiency
for try await post in ghostingKit.postsStream(pageSize: 10) {
    print("Processing post: \(post.title)")
}
```

## Error Handling

GhostingKit provides comprehensive error handling with detailed error types:

```swift
do {
    let posts = try await ghostingKit.getPosts()
} catch GhostingKitError.invalidURL(let url) {
    print("Invalid URL: \(url)")
} catch GhostingKitError.httpError(let statusCode, let message) {
    print("HTTP \(statusCode): \(message ?? "Unknown error")")
} catch GhostingKitError.resourceNotFound(let type, let identifier) {
    print("\(type) with ID \(identifier) not found")
} catch GhostingKitError.networkError(let error) {
    print("Network error: \(error)")
} catch GhostingKitError.cancelled {
    print("Request was cancelled")
} catch GhostingKitError.timeout {
    print("Request timed out")
} catch {
    print("Unknown error: \(error)")
}
```

## SwiftUI Integration

GhostingKit works seamlessly with SwiftUI. Check out the included example app for complete implementations of:

- 📱 Posts list with navigation to detail views
- 👤 Authors list with author detail views
- 🏷️ Tags list with tag detail views
- 📄 Pages list with page detail views
- 🔍 Full-text search and filtering
- ⚡ Async image loading
- 🎨 Modern SwiftUI design patterns

## Example Views

### Posts List

```swift
struct PostsView: View {
    @State private var posts: [GhostPost] = []
    let ghostingKit: GhostingKit
    
    var body: some View {
        List(posts, id: \.id) { post in
            NavigationLink(destination: PostDetailView(post: post)) {
                VStack(alignment: .leading) {
                    Text(post.title)
                        .font(.headline)
                    Text(post.excerpt ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .task {
            do {
                let response = try await ghostingKit.getPosts(include: "authors,tags")
                posts = response.posts
            } catch {
                print("Error loading posts: \(error)")
            }
        }
    }
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup

1. Clone the repository
2. Open `Package.swift` in Xcode
3. Run tests with ⌘+U
4. Check out the example app in the `Ghosting` folder

### Running Tests

```bash
# Run all tests
swift test

# Run only unit tests (no network required)
swift test --filter MockGhostingKitTests

# Run integration tests (requires network)
swift test --filter integration
```

## License

GhostingKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Ghost Content API

This library interacts with the Ghost Content API. For more information about Ghost and its API, visit:

- [Ghost Official Website](https://ghost.org)
- [Ghost Content API Documentation](https://ghost.org/docs/content-api/)
- [Ghost Admin API Documentation](https://ghost.org/docs/admin-api/)

## Changelog

### 1.0.0
- Initial release
- Complete Ghost Content API coverage
- SwiftUI example app
- Comprehensive test suite
- Modern Swift async/await support
- Caching, retry logic, and request cancellation
- Type-safe models with proper Date handling
- Secure configuration management