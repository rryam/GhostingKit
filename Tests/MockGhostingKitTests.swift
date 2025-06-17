import Testing
import Foundation
@testable import GhostingKit

/// Mock implementation for testing without network dependencies
@Suite(.serialized)
struct MockGhostingKitTests {
    
    /// Test configuration creation
    @Test("Configuration creation and validation")
    func testConfiguration() throws {
        // Test valid configuration
        let config = GhostingKitConfiguration(
            adminDomain: "test.ghost.io",
            apiKey: "test-api-key"
        )
        
        #expect(config.adminDomain == "test.ghost.io")
        #expect(config.apiKey == "test-api-key")
        #expect(config.apiVersion == "v5.0")
        
        // Test GhostingKit initialization with configuration
        let _ = try GhostingKit(
            adminDomain: config.adminDomain,
            apiKey: config.apiKey
        )
        // Just verify it was created successfully (no need to compare to nil)
    }
    
    /// Test error handling for invalid domains
    @Test("Invalid domain error handling")
    func testInvalidDomainError() {
        #expect(throws: GhostingKitError.self) {
            _ = try GhostingKit(adminDomain: "", apiKey: "valid-key")
        }
    }
    
    /// Test error handling for invalid API keys
    @Test("Invalid API key error handling")
    func testInvalidAPIKeyError() {
        #expect(throws: GhostingKitError.self) {
            _ = try GhostingKit(adminDomain: "valid.domain.com", apiKey: "")
        }
    }
    
    /// Test retry configuration
    @Test("Retry configuration")
    func testRetryConfiguration() {
        let config = GhostingKitRetryConfiguration(
            maxAttempts: 5,
            baseDelay: 2.0,
            useExponentialBackoff: true,
            maxDelay: 30.0
        )
        
        #expect(config.maxAttempts == 5)
        #expect(config.baseDelay == 2.0)
        #expect(config.useExponentialBackoff == true)
        #expect(config.maxDelay == 30.0)
        
        // Test delay calculation
        #expect(config.delay(for: 1) == 2.0)
        #expect(config.delay(for: 2) == 4.0)
        #expect(config.delay(for: 3) == 8.0)
        
        // Test max delay cap
        let delay5 = config.delay(for: 5)
        #expect(delay5 <= 30.0)
    }
    
    /// Test cache configuration
    @Test("Cache configuration")
    func testCacheConfiguration() {
        let config = GhostingKitCacheConfiguration(
            ttl: 600,
            maxItems: 50,
            isEnabled: true
        )
        
        #expect(config.ttl == 600)
        #expect(config.maxItems == 50)
        #expect(config.isEnabled == true)
        
        // Test disabled cache
        let disabledConfig = GhostingKitCacheConfiguration.disabled
        #expect(disabledConfig.isEnabled == false)
    }
    
    /// Test error types and localization
    @Test("Error types and descriptions")
    func testErrorTypes() {
        let invalidURL = GhostingKitError.invalidURL("test-url")
        #expect(invalidURL.localizedDescription.contains("Invalid URL"))
        
        let httpError = GhostingKitError.httpError(statusCode: 404, message: "Not found")
        #expect(httpError.localizedDescription.contains("404"))
        
        let resourceNotFound = GhostingKitError.resourceNotFound(type: "Post", identifier: "123")
        #expect(resourceNotFound.localizedDescription.contains("Post not found"))
        
        let invalidDomain = GhostingKitError.invalidAdminDomain("bad-domain")
        #expect(invalidDomain.localizedDescription.contains("Invalid admin domain"))
        
        let invalidAPIKey = GhostingKitError.invalidAPIKey
        #expect(invalidAPIKey.localizedDescription.contains("Invalid or missing API key"))
        
        let timeout = GhostingKitError.timeout
        #expect(timeout.localizedDescription.contains("timed out"))
        
        let cancelled = GhostingKitError.cancelled
        #expect(cancelled.localizedDescription.contains("cancelled"))
    }
    
    /// Test pagination helper
    @Test("Pagination helper functionality")
    func testPagination() {
        let meta = GhostPagination(page: 2, limit: 10, pages: 5, total: 50)
        let pagination = GhostingKitPagination(from: meta)
        
        #expect(pagination.currentPage == 2)
        #expect(pagination.pageSize == 10)
        #expect(pagination.totalPages == 5)
        #expect(pagination.totalCount == 50)
        
        #expect(pagination.hasNextPage == true)
        #expect(pagination.hasPreviousPage == true)
        #expect(pagination.nextPage == 3)
        #expect(pagination.previousPage == 1)
        
        // Test edge cases
        let firstPageMeta = GhostPagination(page: 1, limit: 10, pages: 5, total: 50)
        let firstPagePagination = GhostingKitPagination(from: firstPageMeta)
        #expect(firstPagePagination.hasPreviousPage == false)
        #expect(firstPagePagination.previousPage == nil)
        
        let lastPageMeta = GhostPagination(page: 5, limit: 10, pages: 5, total: 50)
        let lastPagePagination = GhostingKitPagination(from: lastPageMeta)
        #expect(lastPagePagination.hasNextPage == false)
        #expect(lastPagePagination.nextPage == nil)
    }
    
    /// Test model initialization and properties
    @Test("Model initialization")
    func testModelInitialization() throws {
        let date = Date()
        
        // Test GhostPost/GhostContent
        let post = GhostPost(
            slug: "test-post",
            id: "123",
            uuid: "uuid-123",
            title: "Test Post",
            html: "<p>Test content</p>",
            commentId: "comment-123",
            featureImage: "https://example.com/image.jpg",
            featureImageAlt: "Alt text",
            featureImageCaption: "Caption",
            featured: true,
            visibility: "public",
            createdAt: date,
            updatedAt: date,
            publishedAt: date,
            customExcerpt: "Custom excerpt",
            codeinjectionHead: "<script></script>",
            codeinjectionFoot: nil,
            customTemplate: nil,
            canonicalUrl: "https://example.com/canonical",
            url: "https://example.com/test-post",
            excerpt: "Test excerpt",
            readingTime: 5,
            access: true,
            ogImage: nil,
            ogTitle: nil,
            ogDescription: nil,
            twitterImage: nil,
            twitterTitle: nil,
            twitterDescription: nil,
            metaTitle: nil,
            metaDescription: nil,
            emailSubject: nil,
            tags: nil,
            authors: nil
        )
        
        #expect(post.id == "123")
        #expect(post.title == "Test Post")
        #expect(post.featured == true)
        #expect(post.readingTime == 5)
        
        // Test GhostAuthor creation (using JSON data since no public init)
        let authorJSON = """
        {
            "id": "author-123",
            "slug": "test-author",
            "name": "Test Author",
            "profile_image": "https://example.com/profile.jpg",
            "cover_image": null,
            "bio": "Test bio",
            "website": "https://example.com",
            "location": "Test Location",
            "facebook": null,
            "twitter": null,
            "meta_title": null,
            "meta_description": null,
            "url": "https://example.com/author/test-author",
            "count": null
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let author = try decoder.decode(GhostAuthor.self, from: authorJSON)
        
        #expect(author.id == "author-123")
        #expect(author.name == "Test Author")
        #expect(author.location == "Test Location")
        
        // Test GhostTag creation (using JSON data since no public init)
        let tagJSON = """
        {
            "id": "tag-123",
            "slug": "test-tag",
            "name": "Test Tag",
            "description": "Test description",
            "feature_image": null,
            "visibility": "public",
            "meta_title": null,
            "meta_description": null,
            "og_image": null,
            "og_title": null,
            "og_description": null,
            "twitter_image": null,
            "twitter_title": null,
            "twitter_description": null,
            "codeinjection_head": null,
            "codeinjection_foot": null,
            "canonical_url": null,
            "accent_color": "#FF0000",
            "url": "https://example.com/tag/test-tag",
            "count": null
        }
        """.data(using: .utf8)!
        
        let tagDecoder = JSONDecoder()
        tagDecoder.dateDecodingStrategy = .iso8601
        let tag = try tagDecoder.decode(GhostTag.self, from: tagJSON)
        
        #expect(tag.id == "tag-123")
        #expect(tag.name == "Test Tag")
        #expect(tag.accentColor == "#FF0000")
    }
    
    /// Test pagination parameters
    @Test("Pagination parameters validation")
    func testPaginationParameters() {
        let params = PaginationParameters(page: 2, limit: 25)
        #expect(params.page == 2)
        #expect(params.limit == 25)
        
        // Test bounds checking
        let invalidParams = PaginationParameters(page: -1, limit: 200)
        #expect(invalidParams.page == 1) // Should be clamped to minimum
        #expect(invalidParams.limit == 100) // Should be clamped to maximum
        
        let zeroParams = PaginationParameters(page: 0, limit: 0)
        #expect(zeroParams.page == 1)
        #expect(zeroParams.limit == 1)
    }
}

/// Tests for environment-based configuration (may require environment setup)
@Suite(.tags(.external))
struct EnvironmentConfigurationTests {
    
    /// Test configuration from environment variables
    /// Note: This test requires setting GHOST_ADMIN_DOMAIN and GHOST_API_KEY environment variables
    @Test("Configuration from environment variables", .enabled(if: ProcessInfo.processInfo.environment["GHOST_ADMIN_DOMAIN"] != nil))
    func testEnvironmentConfiguration() throws {
        let config = try GhostingKitConfiguration.fromEnvironment()
        #expect(!config.adminDomain.isEmpty)
        #expect(!config.apiKey.isEmpty)
    }
}

/// Test tags for organizing tests
extension Tag {
    @Tag static var external: Self
}