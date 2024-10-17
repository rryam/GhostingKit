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
  
  /// Tests fetching a specific page by its slug from the Ghost Content API using PhantomKit.
  ///
  /// This test case initializes a PhantomKit instance with the demo Ghost site's credentials
  /// and attempts to fetch a specific page by its slug. It verifies that the API call succeeds
  /// and returns the expected page data.
  ///
  /// - Note: This test uses the public demo Ghost site (https://demo.ghost.io) and its Content API key.
  ///         The API key used here is for demonstration purposes only and may change in the future.
  ///
  /// - Important: This test requires an active internet connection to succeed.
  @Test("Fetch specific page by slug from Ghost Content API")
  func fetchPageBySlug() async throws {
    // Arrange
    let phantomKit = PhantomKit(
      adminDomain: "demo.ghost.io",
      apiKey: "22444f78447824223cefc48062"
    )
    let expectedSlug = "about"
    
    // Act
    let page = try await phantomKit.getPageBySlug(slug: expectedSlug)
    
    // Assert
    #expect(page.slug == expectedSlug, "Page slug should match the requested slug")
    #expect(page.id == "62416b8cfb349a003cafc2f1", "Page ID should match expected value")
    #expect(page.uuid == "0ebbf5c2-6014-40d9-a970-bcdca3b869ab", "Page UUID should match expected value")
    #expect(page.title == "About this theme", "Page title should match expected value")
    #expect(!page.html.isEmpty, "Page HTML content should not be empty")
    #expect(page.commentId == "62416b8cfb349a003cafc2f1", "Page comment ID should match expected value")
    #expect(page.featureImage == nil, "Page feature image should be nil")
    #expect(page.featured == false, "Page featured status should be false")
    #expect(page.visibility == "public", "Page visibility should be public")
    #expect(page.createdAt == "2022-03-28T08:02:20.000+00:00", "Page created at should match expected value")
    #expect(page.updatedAt == "2022-05-23T10:46:48.000+00:00", "Page updated at should match expected value")
    #expect(page.publishedAt == "2022-03-29T14:12:53.000+00:00", "Page published at should match expected value")
    #expect(page.customExcerpt == nil, "Page custom excerpt should be nil")
    #expect(page.codeinjectionHead == nil, "Page code injection head should be nil")
    #expect(page.codeinjectionFoot == nil, "Page code injection foot should be nil")
    #expect(page.customTemplate == nil, "Page custom template should be nil")
    #expect(page.canonicalUrl == nil, "Page canonical URL should be nil")
    #expect(page.url == "https://demo.ghost.io/about/", "Page URL should match expected value")
    #expect(!page.excerpt.isEmpty, "Page excerpt should not be empty")
    #expect(page.readingTime == 1, "Page reading time should be 1 minute")
    #expect(page.access == true, "Page access should be true")
    #expect(page.ogImage == nil, "Page OG image should be nil")
    #expect(page.ogTitle == nil, "Page OG title should be nil")
    #expect(page.ogDescription == nil, "Page OG description should be nil")
    #expect(page.twitterImage == nil, "Page Twitter image should be nil")
    #expect(page.twitterTitle == nil, "Page Twitter title should be nil")
    #expect(page.twitterDescription == nil, "Page Twitter description should be nil")
    #expect(page.metaTitle == nil, "Page meta title should be nil")
    #expect(page.metaDescription == nil, "Page meta description should be nil")
    #expect(page.featureImageAlt == nil, "Page feature image alt should be nil")
    #expect(page.featureImageCaption == nil, "Page feature image caption should be nil")
  }
}
