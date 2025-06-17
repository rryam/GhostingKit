import Testing
import Foundation
@testable import GhostingKit

extension Tag {
    @Tag static var integration: Self
}

@Suite struct GhostingKitTests {
  
  /// Tests fetching posts from the Ghost Content API using GhostingKit.
  ///
  /// This test case initializes a GhostingKit instance with the demo Ghost site's credentials
  /// and attempts to fetch posts. It verifies that the API call succeeds and returns valid data.
  ///
  /// - Note: This test uses the public demo Ghost site (https://demo.ghost.io) and its Content API key.
  ///         The API key used here is for demonstration purposes only and may change in the future.
  ///
  /// - Important: This test requires an active internet connection to succeed.
  @Test("Fetch posts from Ghost Content API", .tags(.integration))
  func fetchPosts() async throws {
    // Arrange
    let ghostingKit = try GhostingKit(
      adminDomain: "demo.ghost.io",
      apiKey: "22444f78447824223cefc48062"
    )
    
    // Act
    let postsResponse = try await ghostingKit.getPosts(limit: 15)
    
    // Assert
    #expect(!postsResponse.posts.isEmpty, "The response should contain at least one post")
    #expect(postsResponse.posts.count == 15, "The response should contain 15 posts")

    if let firstPost = postsResponse.posts.first {
      #expect(!firstPost.id.isEmpty, "Post ID should not be empty")
      #expect(!firstPost.title.isEmpty, "Post title should not be empty")
      #expect(firstPost.publishedAt != nil, "Published date should not be nil")
      // Note: Specific post IDs and content may change on the demo site
      // so we only test for general structure and data presence
    }
    
    if let lastPost = postsResponse.posts.last {
      #expect(!lastPost.id.isEmpty, "Last post ID should not be empty")
      #expect(!lastPost.title.isEmpty, "Last post title should not be empty")
      #expect(!lastPost.slug.isEmpty, "Last post slug should not be empty")
    }
  }
  
  /// Tests fetching a specific tag by its ID from the Ghost Content API using GhostingKit.
  ///
  /// This test case initializes a GhostingKit instance with the demo Ghost site's credentials
  /// and attempts to fetch a specific tag by its ID. It verifies that the API call succeeds
  /// and returns the expected tag data.
  ///
  /// - Note: This test uses the public demo Ghost site (https://demo.ghost.io) and its Content API key.
  ///         The API key used here is for demonstration purposes only and may change in the future.
  ///
  /// - Important: This test requires an active internet connection to succeed.
  @Test("Fetch specific tag by ID from Ghost Content API", .tags(.integration))
  func fetchTagById() async throws {
    // Arrange
    let ghostingKit = try GhostingKit(
      adminDomain: "demo.ghost.io",
      apiKey: "22444f78447824223cefc48062"
    )
    let _ = "59799bbd6ebb2f00243a33db"
    
    // First get all tags to find a valid one
    let tagsResponse = try await ghostingKit.getTags(limit: 1)
    guard let tag = tagsResponse.tags.first else {
      #expect(Bool(false), "No tags found on demo site")
      return
    }
    
    // Act - fetch the same tag by ID
    let fetchedTag = try await ghostingKit.getTag(id: tag.id)
    
    // Assert
    #expect(fetchedTag.id == tag.id, "Tag ID should match the requested ID")
    #expect(!fetchedTag.name.isEmpty, "Tag name should not be empty")
    #expect(!fetchedTag.slug.isEmpty, "Tag slug should not be empty")
    #expect(fetchedTag.visibility == "public", "Tag visibility should be public")
  }
  
  /// Tests fetching a specific page by its slug from the Ghost Content API using GhostingKit.
  ///
  /// This test case initializes a GhostingKit instance with the demo Ghost site's credentials
  /// and attempts to fetch a specific page by its slug. It verifies that the API call succeeds
  /// and returns the expected page data.
  ///
  /// - Note: This test uses the public demo Ghost site (https://demo.ghost.io) and its Content API key.
  ///         The API key used here is for demonstration purposes only and may change in the future.
  ///
  /// - Important: This test requires an active internet connection to succeed.
  @Test("Fetch specific page by slug from Ghost Content API", .tags(.integration))
  func fetchPageBySlug() async throws {
    // Arrange
    let ghostingKit = try GhostingKit(
      adminDomain: "demo.ghost.io",
      apiKey: "22444f78447824223cefc48062"
    )
    // First get all pages to find a valid one
    let pagesResponse = try await ghostingKit.getPages(limit: 1)
    guard let page = pagesResponse.pages.first else {
      #expect(Bool(false), "No pages found on demo site")
      return
    }
    
    // Act - fetch the same page by slug
    let fetchedPage = try await ghostingKit.getPageBySlug(slug: page.slug)
    
    // Assert
    #expect(fetchedPage.slug == page.slug, "Page slug should match the requested slug")
    #expect(fetchedPage.id == page.id, "Page ID should match expected value")
    #expect(!fetchedPage.title.isEmpty, "Page title should not be empty")
    #expect(fetchedPage.html != nil, "Page HTML content should not be nil")
    #expect(fetchedPage.visibility == "public", "Page visibility should be public")
    #expect(fetchedPage.access == true, "Page access should be true")
    
    // Test date parsing (these are non-optional Date types now)
    #expect(fetchedPage.createdAt > Date(timeIntervalSince1970: 0), "Created date should be parsed")
    #expect(fetchedPage.updatedAt > Date(timeIntervalSince1970: 0), "Updated date should be parsed")
    if let publishedAt = fetchedPage.publishedAt {
      #expect(publishedAt > Date(timeIntervalSince1970: 0), "Published date should be parsed if present")
    }
  }
  
  /// Tests fetching a specific author by their ID from the Ghost Content API using GhostingKit.
  ///
  /// This test case initializes a GhostingKit instance with the demo Ghost site's credentials
  /// and attempts to fetch a specific author by their ID. It verifies that the API call succeeds
  /// and returns the expected author data.
  ///
  /// - Note: This test uses the public demo Ghost site (https://demo.ghost.io) and its Content API key.
  ///         The API key used here is for demonstration purposes only and may change in the future.
  ///
  /// - Important: This test requires an active internet connection to succeed.
  @Test("Fetch specific author by ID from Ghost Content API", .tags(.integration))
  func fetchAuthorById() async throws {
    // Arrange
    let ghostingKit = try GhostingKit(
      adminDomain: "demo.ghost.io",
      apiKey: "22444f78447824223cefc48062"
    )
    // First get all authors to find a valid one
    let authorsResponse = try await ghostingKit.getAuthors(limit: 1)
    guard let author = authorsResponse.authors.first else {
      #expect(Bool(false), "No authors found on demo site")
      return
    }
    
    // Act - fetch the same author by ID
    let fetchedAuthor = try await ghostingKit.getAuthor(id: author.id)
    
    // Assert
    #expect(fetchedAuthor.id == author.id, "Author ID should match the requested ID")
    #expect(!fetchedAuthor.name.isEmpty, "Author name should not be empty")
    #expect(!fetchedAuthor.slug.isEmpty, "Author slug should not be empty")
    #expect(!fetchedAuthor.url.isEmpty, "Author URL should not be empty")
  }
  
  /// Test new API methods
  @Test("Test new getPost and getPostBySlug methods", .tags(.integration))
  func testNewPostMethods() async throws {
    let ghostingKit = try GhostingKit(
      adminDomain: "demo.ghost.io",
      apiKey: "22444f78447824223cefc48062"
    )
    
    // Get a post first to test individual post fetching
    let postsResponse = try await ghostingKit.getPosts(limit: 1)
    guard let firstPost = postsResponse.posts.first else {
      #expect(Bool(false), "No posts found on demo site")
      return
    }
    
    // Test getPost by ID
    let fetchedPost = try await ghostingKit.getPost(id: firstPost.id)
    #expect(fetchedPost.id == firstPost.id)
    #expect(fetchedPost.title == firstPost.title)
    
    // Test getPostBySlug
    let fetchedPostBySlug = try await ghostingKit.getPostBySlug(slug: firstPost.slug)
    #expect(fetchedPostBySlug.id == firstPost.id)
    #expect(fetchedPostBySlug.slug == firstPost.slug)
  }
  
  /// Test cancellable requests
  @Test("Test cancellable requests", .tags(.integration))
  func testCancellableRequests() async throws {
    let ghostingKit = try GhostingKit(
      adminDomain: "demo.ghost.io",
      apiKey: "22444f78447824223cefc48062"
    )
    
    // Test cancellable posts request
    let cancellableRequest = await ghostingKit.getPostsCancellable(limit: 5)
    #expect(!cancellableRequest.taskId.isEmpty, "Task ID should not be empty")
    
    // Let the request complete
    let result = try await cancellableRequest.task.value
    #expect(!result.posts.isEmpty, "Should have posts")
  }
  
  /// Test pagination helpers
  @Test("Test pagination with actual API", .tags(.integration))
  func testPaginationHelpers() async throws {
    let ghostingKit = try GhostingKit(
      adminDomain: "demo.ghost.io",
      apiKey: "22444f78447824223cefc48062"
    )
    
    let response = try await ghostingKit.getPosts(limit: 5, page: 1)
    if let pagination = response.pagination {
      #expect(pagination.currentPage == 1)
      #expect(pagination.pageSize == 5)
      #expect(pagination.totalCount > 0)
    }
  }
}
