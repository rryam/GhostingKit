import Testing
@testable import PhantomKit

@Suite struct PhantomKitTests {
  
  /// Tests fetching posts from the Ghost Content API using PhantomKit.
  ///
  /// This test case initializes a PhantomKit instance with the demo Ghost site's credentials
  /// and attempts to fetch posts. It verifies that the API call succeeds and returns valid data.
  ///
  /// - Note: This test uses the public demo Ghost site (https://demo.ghost.io) and its Content API key.
  ///         The API key used here is for demonstration purposes only and may change in the future.
  ///
  /// - Important: This test requires an active internet connection to succeed.
  @Test("Fetch posts from Ghost Content API")
  func fetchPosts() async throws {
    // Arrange
    let phantomKit = PhantomKit(
      adminDomain: "demo.ghost.io",
      apiKey: "22444f78447824223cefc48062"
    )
    
    // Act
    let postsResponse = try await phantomKit.getPosts(limit: 15)
    
    // Assert
    #expect(!postsResponse.posts.isEmpty, "The response should contain at least one post")
    #expect(postsResponse.posts.count == 15, "The response should contain 15 posts")
    
    if let firstPost = postsResponse.posts.first {
      #expect(!firstPost.id.isEmpty, "Post ID should not be empty")
      #expect(!firstPost.title.isEmpty, "Post title should not be empty")
      #expect(firstPost.publishedAt != nil, "Published date should not be nil")
      #expect(firstPost.id == "605360bbce93e1003bd6ddd6", "First post ID should match expected value")
      #expect(firstPost.title == "Start here for a quick overview of everything you need to know", "First post title should match expected value")
      #expect(firstPost.slug == "welcome", "First post slug should match expected value")
    }
    
    if let lastPost = postsResponse.posts.last {
      #expect(lastPost.id == "5979a77cdf093500228e95ea", "Last post ID should match expected value")
      #expect(lastPost.title == "Gettysburg Address", "Last post title should match expected value")
      #expect(lastPost.slug == "gettysburg-address", "Last post slug should match expected value")
    }
  }
}