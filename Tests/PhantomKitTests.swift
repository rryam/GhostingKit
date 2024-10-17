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
  
  /// Tests fetching a specific tag by its ID from the Ghost Content API using PhantomKit.
  ///
  /// This test case initializes a PhantomKit instance with the demo Ghost site's credentials
  /// and attempts to fetch a specific tag by its ID. It verifies that the API call succeeds
  /// and returns the expected tag data.
  ///
  /// - Note: This test uses the public demo Ghost site (https://demo.ghost.io) and its Content API key.
  ///         The API key used here is for demonstration purposes only and may change in the future.
  ///
  /// - Important: This test requires an active internet connection to succeed.
  @Test("Fetch specific tag by ID from Ghost Content API")
  func fetchTagById() async throws {
    // Arrange
    let phantomKit = PhantomKit(
      adminDomain: "demo.ghost.io",
      apiKey: "22444f78447824223cefc48062"
    )
    let expectedTagId = "59799bbd6ebb2f00243a33db"
    
    // Act
    let tag = try await phantomKit.getTag(id: expectedTagId)
    
    // Assert
    #expect(tag.id == expectedTagId, "Tag ID should match the requested ID")
    #expect(tag.name == "Getting Started", "Tag name should match expected value")
    #expect(tag.slug == "getting-started", "Tag slug should match expected value")
    #expect(tag.description == nil, "Tag description should be nil")
    #expect(tag.featureImage == nil, "Tag feature image should be nil")
    #expect(tag.visibility == "public", "Tag visibility should be public")
    #expect(tag.metaTitle == nil, "Tag meta title should be nil")
    #expect(tag.metaDescription == nil, "Tag meta description should be nil")
    #expect(tag.ogImage == nil, "Tag OG image should be nil")
    #expect(tag.ogTitle == nil, "Tag OG title should be nil")
    #expect(tag.ogDescription == nil, "Tag OG description should be nil")
    #expect(tag.twitterImage == nil, "Tag Twitter image should be nil")
    #expect(tag.twitterTitle == nil, "Tag Twitter title should be nil")
    #expect(tag.twitterDescription == nil, "Tag Twitter description should be nil")
    #expect(tag.codeinjectionHead == nil, "Tag code injection head should be nil")
    #expect(tag.codeinjectionFoot == nil, "Tag code injection foot should be nil")
    #expect(tag.canonicalUrl == nil, "Tag canonical URL should be nil")
    #expect(tag.accentColor == nil, "Tag accent color should be nil")
    #expect(tag.url == "https://demo.ghost.io/tag/getting-started/", "Tag URL should match expected value")
  }
}