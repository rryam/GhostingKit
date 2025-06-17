// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

/// An actor representing the Ghost Content API client.
///
/// The `GhostingKit` actor provides methods to interact with Ghost's RESTful Content API,
/// allowing read-only access to published content. It simplifies the process of fetching
/// posts, pages, tags, authors, tiers, and settings from a Ghost site.
///
/// - Important: This actor requires a valid API key and admin domain to function correctly.
///
/// - Note: The Content API is designed to be fully cacheable, allowing frequent data fetching without limitations.
public actor GhostingKit {
  /// The base URL for the Ghost Content API.
  private let baseURL: URL

  /// The API key used for authentication.
  private let apiKey: String

  /// The API version to use for requests.
  private let apiVersion: String

  /// The URL session used for network requests.
  private let urlSession: URLSession
  
  /// The cache instance for storing responses
  internal var cache: GhostingKitCache?
  
  /// The retry configuration for network requests
  private let retryConfiguration: GhostingKitRetryConfiguration
  
  /// Storage for active tasks to support cancellation
  private var activeTasks: [String: Task<Data, Error>] = [:]

  /// Set the cache instance
  internal func setCache(_ newCache: GhostingKitCache) {
    self.cache = newCache
  }
  
  /// Cancel a specific request by its task ID
  public func cancelRequest(taskId: String) {
    activeTasks[taskId]?.cancel()
    activeTasks.removeValue(forKey: taskId)
  }
  
  /// Cancel all active requests
  public func cancelAllRequests() {
    for task in activeTasks.values {
      task.cancel()
    }
    activeTasks.removeAll()
  }

  /// Initializes a new instance of the GhostingKit actor.
  ///
  /// - Parameters:
  ///   - adminDomain: The admin domain of the Ghost site (e.g., "example.ghost.io").
  ///   - apiKey: The Content API key for authentication.
  ///   - apiVersion: The API version to use (default is "v5.0").
  ///   - urlSession: The URL session to use for network requests (default is shared session).
  ///
  /// - Important: Ensure you're using the correct admin domain and HTTPS protocol for consistent behavior.
  public init(
    adminDomain: String,
    apiKey: String,
    apiVersion: String = "v5.0",
    urlSession: URLSession = .shared,
    retryConfiguration: GhostingKitRetryConfiguration = .default
  ) throws {
    guard !adminDomain.isEmpty else {
      throw GhostingKitError.invalidAdminDomain(adminDomain)
    }
    guard !apiKey.isEmpty else {
      throw GhostingKitError.invalidAPIKey
    }
    guard let url = URL(string: "https://\(adminDomain)/ghost/api/content/") else {
      throw GhostingKitError.invalidURL("https://\(adminDomain)/ghost/api/content/")
    }
    self.baseURL = url
    self.apiKey = apiKey
    self.apiVersion = apiVersion
    self.urlSession = urlSession
    self.retryConfiguration = retryConfiguration
    self.cache = GhostingKitCache(configuration: .default)
  }

  /// Performs a GET request to the specified endpoint.
  ///
  /// - Parameters:
  ///   - endpoint: The API endpoint to request (e.g., "posts", "pages", "tags").
  ///   - parameters: Additional query parameters for the request.
  ///
  /// - Returns: The response data from the API.
  ///
  /// - Throws: An error if the network request fails or returns an invalid response.
  private func get(
    _ endpoint: String,
    parameters: [String: String] = [:],
    taskId: String? = nil
  ) async throws -> Data {
    // Check cache first
    if let cachedData = await cache?.get(endpoint: endpoint, parameters: parameters) {
      return cachedData
    }
    
    var lastError: Error?
    
    for attempt in 1...retryConfiguration.maxAttempts {
      do {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: true) else {
          throw GhostingKitError.invalidURL(endpoint)
        }
        
        var queryItems = [URLQueryItem(name: "key", value: apiKey)]
        queryItems += parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        components.queryItems = queryItems

        guard let url = components.url else {
          throw GhostingKitError.invalidURL(components.description)
        }
        
        var request = URLRequest(url: url)
        request.addValue("v\(apiVersion)", forHTTPHeaderField: "Accept-Version")

        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
          throw GhostingKitError.networkError(URLError(.badServerResponse))
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
          let message = String(data: data, encoding: .utf8)
          let error = GhostingKitError.httpError(statusCode: httpResponse.statusCode, message: message)
          
          // Check if we should retry this HTTP error
          if retryConfiguration.retryableStatusCodes.contains(httpResponse.statusCode) && attempt < retryConfiguration.maxAttempts {
            lastError = error
            let delay = retryConfiguration.delay(for: attempt)
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            continue
          } else {
            throw error
          }
        }
        
        // Store in cache for successful responses
        await cache?.set(endpoint: endpoint, parameters: parameters, data: data)
        
        return data
      } catch let error as URLError where error.code == .cancelled {
        throw GhostingKitError.cancelled
      } catch let error as URLError where error.code == .timedOut {
        let timeoutError = GhostingKitError.timeout
        if attempt < retryConfiguration.maxAttempts {
          lastError = timeoutError
          let delay = retryConfiguration.delay(for: attempt)
          try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
          continue
        } else {
          throw timeoutError
        }
      } catch let error as GhostingKitError {
        lastError = error
        // Only retry on network errors, not on validation errors
        switch error {
        case .networkError:
          if attempt < retryConfiguration.maxAttempts {
            let delay = retryConfiguration.delay(for: attempt)
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            continue
          }
        default:
          break
        }
        throw error
      } catch {
        let networkError = GhostingKitError.networkError(error)
        if attempt < retryConfiguration.maxAttempts {
          lastError = networkError
          let delay = retryConfiguration.delay(for: attempt)
          try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
          continue
        } else {
          throw networkError
        }
      }
    }
    
    throw lastError ?? GhostingKitError.networkError(URLError(.unknown))
  }
  /// Fetches posts from the Ghost Content API.
  ///
  /// This method retrieves posts from the Ghost Content API, allowing you to customize the query
  /// with various parameters.
  ///
  /// - Parameters:
  ///   - limit: The maximum number of posts to return (default is 15).
  ///   - page: The page of posts to return (default is 1).
  ///   - include: Related data to include in the response (e.g., "authors,tags").
  ///   - filter: A filter query to apply to the posts (e.g., "tag:getting-started").
  ///
  /// - Returns: A `GhostPostsResponse` containing an array of `GhostPost` objects.
  ///
  /// - Throws: An error if the network request fails, returns an invalid response, or fails to decode the JSON.
  ///
  /// - Note: The `filter` parameter allows you to narrow down the posts based on specific criteria.
  ///         For example, you can use "tag:getting-started" to fetch only posts with the "getting-started" tag.
  public func getPosts(
    limit: Int = 15,
    page: Int = 1,
    include: String? = nil,
    filter: String? = nil
  ) async throws -> GhostPostsResponse {
    var parameters: [String: String] = [
      "limit": String(limit),
      "page": String(page)
    ]
    if let include = include {
      parameters["include"] = include
    }
    if let filter = filter {
      parameters["filter"] = filter
    }
    let data = try await get("posts", parameters: parameters)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    do {
      return try decoder.decode(GhostPostsResponse.self, from: data)
    } catch {
      throw GhostingKitError.decodingError(error)
    }
  }

  /// Fetches a specific post by its ID from the Ghost Content API.
  ///
  /// - Parameters:
  ///   - id: The unique identifier of the post.
  ///   - include: Related data to include in the response (e.g., "authors,tags").
  ///
  /// - Returns: A `GhostPost` object representing the requested post.
  ///
  /// - Throws: An error if the network request fails, returns an invalid response, or fails to decode the JSON.
  public func getPost(
    id: String,
    include: String? = nil
  ) async throws -> GhostPost {
    var parameters: [String: String] = [:]
    if let include = include {
      parameters["include"] = include
    }
    let data = try await get("posts/\(id)", parameters: parameters)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let response: GhostPostsResponse
    do {
      response = try decoder.decode(GhostPostsResponse.self, from: data)
    } catch {
      throw GhostingKitError.decodingError(error)
    }
    guard let post = response.posts.first else {
      throw GhostingKitError.resourceNotFound(type: "Post", identifier: id)
    }
    return post
  }

  /// Fetches a specific post by its slug from the Ghost Content API.
  ///
  /// - Parameters:
  ///   - slug: The slug of the post.
  ///   - include: Related data to include in the response (e.g., "authors,tags").
  ///
  /// - Returns: A `GhostPost` object representing the requested post.
  ///
  /// - Throws: An error if the network request fails, returns an invalid response, or fails to decode the JSON.
  public func getPostBySlug(
    slug: String,
    include: String? = nil
  ) async throws -> GhostPost {
    var parameters: [String: String] = [:]
    if let include = include {
      parameters["include"] = include
    }
    let data = try await get("posts/slug/\(slug)", parameters: parameters)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let response: GhostPostsResponse
    do {
      response = try decoder.decode(GhostPostsResponse.self, from: data)
    } catch {
      throw GhostingKitError.decodingError(error)
    }
    guard let post = response.posts.first else {
      throw GhostingKitError.resourceNotFound(type: "Post", identifier: slug)
    }
    return post
  }

  /// Fetches tags from the Ghost Content API.
  
  /// Fetches authors from the Ghost Content API.
  ///
  /// This method retrieves authors who have published posts associated with them from the Ghost Content API.
  ///
  /// - Parameters:
  ///   - limit: The maximum number of authors to return (default is 15).
  ///   - page: The page of authors to return (default is 1).
  ///   - include: Related data to include in the response (e.g., "count.posts").
  ///
  /// - Returns: A `GhostAuthorsResponse` containing an array of `GhostAuthor` objects.
  ///
  /// - Throws: An error if the network request fails, returns an invalid response, or fails to decode the JSON.
  ///
  /// - Note: Authors that are not associated with a post are not returned.
  public func getAuthors(
    limit: Int = 15,
    page: Int = 1,
    include: String? = nil
  ) async throws -> GhostAuthorsResponse {
    var parameters: [String: String] = [
      "limit": String(limit),
      "page": String(page)
    ]
    if let include = include {
      parameters["include"] = include
    }
    let data = try await get("authors", parameters: parameters)
    let decoder = JSONDecoder()
    do {
      return try decoder.decode(GhostAuthorsResponse.self, from: data)
    } catch {
      throw GhostingKitError.decodingError(error)
    }
  }

  /// Fetches a specific author by their ID from the Ghost Content API.
  ///
  /// - Parameters:
  ///   - id: The unique identifier of the author.
  ///   - include: Related data to include in the response (e.g., "count.posts").
  ///
  /// - Returns: A `GhostAuthor` object representing the requested author.
  ///
  /// - Throws: An error if the network request fails, returns an invalid response, or fails to decode the JSON.
  public func getAuthor(
    id: String,
    include: String? = nil
  ) async throws -> GhostAuthor {
    var parameters: [String: String] = [:]
    if let include = include {
      parameters["include"] = include
    }
    let data = try await get("authors/\(id)", parameters: parameters)
    let decoder = JSONDecoder()
    let response: GhostAuthorsResponse
    do {
      response = try decoder.decode(GhostAuthorsResponse.self, from: data)
    } catch {
      throw GhostingKitError.decodingError(error)
    }
    guard let author = response.authors.first else {
      throw GhostingKitError.resourceNotFound(type: "Author", identifier: id)
    }
    return author
  }

  /// Fetches a specific author by their slug from the Ghost Content API.
  ///
  /// - Parameters:
  ///   - slug: The slug of the author.
  ///   - include: Related data to include in the response (e.g., "count.posts").
  ///
  /// - Returns: A `GhostAuthor` object representing the requested author.
  ///
  /// - Throws: An error if the network request fails, returns an invalid response, or fails to decode the JSON.
  public func getAuthorBySlug(
    slug: String,
    include: String? = nil
  ) async throws -> GhostAuthor {
    var parameters: [String: String] = [:]
    if let include = include {
      parameters["include"] = include
    }
    let data = try await get("authors/slug/\(slug)", parameters: parameters)
    let decoder = JSONDecoder()
    let response: GhostAuthorsResponse
    do {
      response = try decoder.decode(GhostAuthorsResponse.self, from: data)
    } catch {
      throw GhostingKitError.decodingError(error)
    }
    guard let author = response.authors.first else {
      throw GhostingKitError.resourceNotFound(type: "Author", identifier: slug)
    }
    return author
  }
  ///
  /// This method retrieves tags from the Ghost Content API. By default, it includes
  /// internal tags. Use the `filter` parameter to limit the response to public tags.
  ///
  /// - Parameters:
  ///   - limit: The maximum number of tags to return (default is 15).
  ///   - page: The page of tags to return (default is 1).
  ///   - include: Related data to include in the response (e.g., "count.posts").
  ///   - filter: A filter to apply to the query (e.g., "visibility:public").
  ///
  /// - Returns: A `GhostTagsResponse` containing an array of `GhostTag` objects.
  ///
  /// - Throws: An error if the network request fails, returns an invalid response, or fails to decode the JSON.
  public func getTags(
    limit: Int = 15,
    page: Int = 1,
    include: String? = nil,
    filter: String? = nil
  ) async throws -> GhostTagsResponse {
    var parameters: [String: String] = [
      "limit": String(limit),
      "page": String(page)
    ]
    if let include = include {
      parameters["include"] = include
    }
    if let filter = filter {
      parameters["filter"] = filter
    }
    let data = try await get("tags", parameters: parameters)
    let decoder = JSONDecoder()
    do {
      return try decoder.decode(GhostTagsResponse.self, from: data)
    } catch {
      throw GhostingKitError.decodingError(error)
    }
  }

  /// Fetches a specific tag by its ID from the Ghost Content API.
  ///
  /// - Parameters:
  ///   - id: The unique identifier of the tag.
  ///   - include: Related data to include in the response (e.g., "count.posts").
  ///
  /// - Returns: A `GhostTag` object representing the requested tag.
  ///
  /// - Throws: An error if the network request fails, returns an invalid response, or fails to decode the JSON.
  public func getTag(
    id: String,
    include: String? = nil
  ) async throws -> GhostTag {
    var parameters: [String: String] = [:]
    if let include = include {
      parameters["include"] = include
    }
    let data = try await get("tags/\(id)", parameters: parameters)
    let decoder = JSONDecoder()
    let response: GhostTagsResponse
    do {
      response = try decoder.decode(GhostTagsResponse.self, from: data)
    } catch {
      throw GhostingKitError.decodingError(error)
    }
    guard let tag = response.tags.first else {
      throw GhostingKitError.resourceNotFound(type: "Tag", identifier: id)
    }
    return tag
  }

  /// Fetches a specific tag by its slug from the Ghost Content API.
  ///
  /// - Parameters:
  ///   - slug: The slug of the tag.
  ///   - include: Related data to include in the response (e.g., "count.posts").
  ///
  /// - Returns: A `GhostTag` object representing the requested tag.
  ///
  /// - Throws: An error if the network request fails, returns an invalid response, or fails to decode the JSON.
  public func getTagBySlug(
    slug: String,
    include: String? = nil
  ) async throws -> GhostTag {
    var parameters: [String: String] = [:]
    if let include = include {
      parameters["include"] = include
    }
    let data = try await get("tags/slug/\(slug)", parameters: parameters)
    let decoder = JSONDecoder()
    let response: GhostTagsResponse
    do {
      response = try decoder.decode(GhostTagsResponse.self, from: data)
    } catch {
      throw GhostingKitError.decodingError(error)
    }
    guard let tag = response.tags.first else {
      throw GhostingKitError.resourceNotFound(type: "Tag", identifier: slug)
    }
    return tag
  }

  /// Fetches pages from the Ghost Content API.
  ///
  /// Pages are static resources that are not included in channels or collections on the Ghost front-end.
  /// This method retrieves only pages that were created as resources and will not contain routes created
  /// with dynamic routing.
  ///
  /// - Parameters:
  ///   - limit: The maximum number of pages to return (default is 15).
  ///   - page: The page number to return (default is 1).
  ///   - include: Related data to include in the response (e.g., "authors,tags").
  ///
  /// - Returns: A `GhostPagesResponse` containing an array of `GhostPage` objects.
  ///
  /// - Throws: An error if the network request fails, returns an invalid response, or fails to decode the JSON.
  public func getPages(
    limit: Int = 15,
    page: Int = 1,
    include: String? = nil
  ) async throws -> GhostPagesResponse {
    var parameters: [String: String] = [
      "limit": String(limit),
      "page": String(page)
    ]
    if let include = include {
      parameters["include"] = include
    }
    let data = try await get("pages", parameters: parameters)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    do {
      return try decoder.decode(GhostPagesResponse.self, from: data)
    } catch {
      throw GhostingKitError.decodingError(error)
    }
  }

  /// Fetches a specific page by its ID from the Ghost Content API.
  ///
  /// - Parameters:
  ///   - id: The unique identifier of the page.
  ///   - include: Related data to include in the response (e.g., "authors,tags").
  ///
  /// - Returns: A `GhostPage` object representing the requested page.
  ///
  /// - Throws: An error if the network request fails, returns an invalid response, or fails to decode the JSON.
  public func getPage(
    id: String,
    include: String? = nil
  ) async throws -> GhostContent {
    var parameters: [String: String] = [:]
    if let include = include {
      parameters["include"] = include
    }
    let data = try await get("pages/\(id)", parameters: parameters)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let response: GhostPagesResponse
    do {
      response = try decoder.decode(GhostPagesResponse.self, from: data)
    } catch {
      throw GhostingKitError.decodingError(error)
    }
    guard let page = response.pages.first else {
      throw GhostingKitError.resourceNotFound(type: "Page", identifier: id)
    }
    return page
  }

  /// Fetches a specific page by its slug from the Ghost Content API.
  ///
  /// - Parameters:
  ///   - slug: The slug of the page.
  ///   - include: Related data to include in the response (e.g., "authors,tags").
  ///
  /// - Returns: A `GhostPage` object representing the requested page.
  ///
  /// - Throws: An error if the network request fails, returns an invalid response, or fails to decode the JSON.
  public func getPageBySlug(
    slug: String,
    include: String? = nil
  ) async throws -> GhostContent {
    var parameters: [String: String] = [:]
    if let include = include {
      parameters["include"] = include
    }
    let data = try await get("pages/slug/\(slug)", parameters: parameters)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let response: GhostPagesResponse
    do {
      response = try decoder.decode(GhostPagesResponse.self, from: data)
    } catch {
      throw GhostingKitError.decodingError(error)
    }
    guard let page = response.pages.first else {
      throw GhostingKitError.resourceNotFound(type: "Page", identifier: slug)
    }
    return page
  }

  /// Fetches tiers from the Ghost Content API.
  ///
  /// Tiers represent membership levels available on the Ghost site.
  ///
  /// - Parameters:
  ///   - limit: The maximum number of tiers to return (default is 15).
  ///   - page: The page of tiers to return (default is 1).
  ///   - include: Related data to include in the response.
  ///   - filter: A filter to apply to the query.
  ///
  /// - Returns: A `GhostTiersResponse` containing an array of `GhostTier` objects.
  ///
  /// - Throws: An error if the network request fails, returns an invalid response, or fails to decode the JSON.
  public func getTiers(
    limit: Int = 15,
    page: Int = 1,
    include: String? = nil,
    filter: String? = nil
  ) async throws -> GhostTiersResponse {
    var parameters: [String: String] = [
      "limit": String(limit),
      "page": String(page)
    ]
    if let include = include {
      parameters["include"] = include
    }
    if let filter = filter {
      parameters["filter"] = filter
    }
    let data = try await get("tiers", parameters: parameters)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    do {
      return try decoder.decode(GhostTiersResponse.self, from: data)
    } catch {
      throw GhostingKitError.decodingError(error)
    }
  }

  /// Fetches a specific tier by its ID from the Ghost Content API.
  ///
  /// - Parameters:
  ///   - id: The unique identifier of the tier.
  ///   - include: Related data to include in the response.
  ///
  /// - Returns: A `GhostTier` object representing the requested tier.
  ///
  /// - Throws: An error if the network request fails, returns an invalid response, or fails to decode the JSON.
  public func getTier(
    id: String,
    include: String? = nil
  ) async throws -> GhostTier {
    var parameters: [String: String] = [:]
    if let include = include {
      parameters["include"] = include
    }
    let data = try await get("tiers/\(id)", parameters: parameters)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let response: GhostTiersResponse
    do {
      response = try decoder.decode(GhostTiersResponse.self, from: data)
    } catch {
      throw GhostingKitError.decodingError(error)
    }
    guard let tier = response.tiers.first else {
      throw GhostingKitError.resourceNotFound(type: "Tier", identifier: id)
    }
    return tier
  }

  /// Fetches settings from the Ghost Content API.
  ///
  /// Settings contain public information about the Ghost site including title, 
  /// description, navigation, and other configuration details.
  ///
  /// - Returns: A `GhostSettings` object containing the site settings.
  ///
  /// - Throws: An error if the network request fails, returns an invalid response, or fails to decode the JSON.
  public func getSettings() async throws -> GhostSettings {
    let data = try await get("settings")
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    do {
      let response = try decoder.decode(GhostSettingsResponse.self, from: data)
      return response.settings
    } catch {
      throw GhostingKitError.decodingError(error)
    }
  }

  // MARK: - Cancellable Request Methods
  
  /// A structure representing a cancellable request task
  public struct CancellableRequest<T: Sendable>: Sendable {
    /// The unique task ID for this request
    public let taskId: String
    
    /// The task that can be awaited for the result
    public let task: Task<T, Error>
    
    /// Cancel this specific request
    public func cancel() {
      task.cancel()
    }
  }
  
  /// Fetches posts with cancellation support
  public func getPostsCancellable(
    limit: Int = 15,
    page: Int = 1,
    include: String? = nil,
    filter: String? = nil
  ) -> CancellableRequest<GhostPostsResponse> {
    let taskId = UUID().uuidString
    
    let task = Task<GhostPostsResponse, Error> {
      defer { activeTasks.removeValue(forKey: taskId) }
      
      var parameters: [String: String] = [
        "limit": String(limit),
        "page": String(page)
      ]
      if let include = include {
        parameters["include"] = include
      }
      if let filter = filter {
        parameters["filter"] = filter
      }
      
      let data = try await get("posts", parameters: parameters, taskId: taskId)
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      do {
        return try decoder.decode(GhostPostsResponse.self, from: data)
      } catch {
        throw GhostingKitError.decodingError(error)
      }
    }
    
    activeTasks[taskId] = Task<Data, Error> {
      _ = try await task.value
      return Data() // This is just to match the Task<Data, Error> type
    }
    
    return CancellableRequest(taskId: taskId, task: task)
  }
  
  /// Fetches a specific post with cancellation support
  public func getPostCancellable(
    id: String,
    include: String? = nil
  ) -> CancellableRequest<GhostPost> {
    let taskId = UUID().uuidString
    
    let task = Task<GhostPost, Error> {
      defer { activeTasks.removeValue(forKey: taskId) }
      
      var parameters: [String: String] = [:]
      if let include = include {
        parameters["include"] = include
      }
      
      let data = try await get("posts/\(id)", parameters: parameters, taskId: taskId)
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      let response: GhostPostsResponse
      do {
        response = try decoder.decode(GhostPostsResponse.self, from: data)
      } catch {
        throw GhostingKitError.decodingError(error)
      }
      guard let post = response.posts.first else {
        throw GhostingKitError.resourceNotFound(type: "Post", identifier: id)
      }
      return post
    }
    
    activeTasks[taskId] = Task<Data, Error> {
      _ = try await task.value
      return Data() // This is just to match the Task<Data, Error> type
    }
    
    return CancellableRequest(taskId: taskId, task: task)
  }
}
