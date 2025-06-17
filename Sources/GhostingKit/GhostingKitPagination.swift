import Foundation

/// A helper struct for managing pagination in Ghost API requests
public struct GhostingKitPagination {
    /// The current page number
    public let currentPage: Int
    
    /// The number of items per page
    public let pageSize: Int
    
    /// The total number of pages available
    public let totalPages: Int
    
    /// The total number of items available
    public let totalCount: Int
    
    /// Whether there is a next page
    public var hasNextPage: Bool {
        currentPage < totalPages
    }
    
    /// Whether there is a previous page
    public var hasPreviousPage: Bool {
        currentPage > 1
    }
    
    /// The next page number, if available
    public var nextPage: Int? {
        hasNextPage ? currentPage + 1 : nil
    }
    
    /// The previous page number, if available
    public var previousPage: Int? {
        hasPreviousPage ? currentPage - 1 : nil
    }
    
    /// Initialize from Ghost API pagination metadata
    internal init(from meta: GhostPagination) {
        self.currentPage = meta.page
        self.pageSize = meta.limit
        self.totalPages = meta.pages
        self.totalCount = meta.total
    }
}

/// Extended response types with pagination helper
extension GhostPostsResponse {
    /// Get pagination information as a helper object
    public var pagination: GhostingKitPagination? {
        if let meta = meta {
            return GhostingKitPagination(from: meta.pagination)
        }
        return nil
    }
}

extension GhostPagesResponse {
    /// Get pagination information as a helper object
    public var pagination: GhostingKitPagination? {
        if let meta = meta {
            return GhostingKitPagination(from: meta.pagination)
        }
        return nil
    }
}

extension GhostTagsResponse {
    /// Get pagination information as a helper object
    public var pagination: GhostingKitPagination? {
        if let meta = meta {
            return GhostingKitPagination(from: meta.pagination)
        }
        return nil
    }
}

extension GhostAuthorsResponse {
    /// Get pagination information as a helper object
    public var pagination: GhostingKitPagination? {
        if let meta = meta {
            return GhostingKitPagination(from: meta.pagination)
        }
        return nil
    }
}

/// Pagination parameters for API requests
public struct PaginationParameters {
    public let page: Int
    public let limit: Int
    
    public init(page: Int = 1, limit: Int = 15) {
        self.page = max(1, page)
        self.limit = min(max(1, limit), 100) // Ghost API typically limits to 100
    }
}

/// Extension to GhostingKit for paginated requests
extension GhostingKit {
    /// Fetches all posts across multiple pages
    ///
    /// - Parameters:
    ///   - pageSize: The number of posts per page (default is 15, max is 100)
    ///   - include: Related data to include in the response
    ///   - filter: A filter query to apply to the posts
    ///   - maxPages: Maximum number of pages to fetch (nil for all pages)
    ///
    /// - Returns: An array of all posts matching the criteria
    public func getAllPosts(
        pageSize: Int = 15,
        include: String? = nil,
        filter: String? = nil,
        maxPages: Int? = nil
    ) async throws -> [GhostPost] {
        var allPosts: [GhostPost] = []
        var currentPage = 1
        var hasMore = true
        
        while hasMore {
            let response = try await getPosts(
                limit: pageSize,
                page: currentPage,
                include: include,
                filter: filter
            )
            
            allPosts.append(contentsOf: response.posts)
            
            if let pagination = response.pagination {
                hasMore = pagination.hasNextPage
                if let maxPages = maxPages, currentPage >= maxPages {
                    hasMore = false
                }
            } else {
                hasMore = false
            }
            
            currentPage += 1
        }
        
        return allPosts
    }
    
    /// Fetches posts with async sequence support for efficient memory usage
    ///
    /// - Parameters:
    ///   - pageSize: The number of posts per page
    ///   - include: Related data to include in the response
    ///   - filter: A filter query to apply to the posts
    ///
    /// - Returns: An AsyncThrowingStream of posts
    public func postsStream(
        pageSize: Int = 15,
        include: String? = nil,
        filter: String? = nil
    ) -> AsyncThrowingStream<GhostPost, Error> {
        AsyncThrowingStream { continuation in
            Task {
                var currentPage = 1
                var hasMore = true
                
                do {
                    while hasMore {
                        let response = try await getPosts(
                            limit: pageSize,
                            page: currentPage,
                            include: include,
                            filter: filter
                        )
                        
                        for post in response.posts {
                            continuation.yield(post)
                        }
                        
                        if let pagination = response.pagination {
                            hasMore = pagination.hasNextPage
                        } else {
                            hasMore = false
                        }
                        
                        currentPage += 1
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}