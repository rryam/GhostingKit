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
    urlSession: URLSession = .shared
  ) {
    self.baseURL = URL(string: "https://\(adminDomain)/ghost/api/content/")!
    self.apiKey = apiKey
    self.apiVersion = apiVersion
    self.urlSession = urlSession
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
    parameters: [String: String] = [:]
  ) async throws -> Data {
    var components = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: true)!
    var queryItems = [URLQueryItem(name: "key", value: apiKey)]
    queryItems += parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    components.queryItems = queryItems

    var request = URLRequest(url: components.url!)
    request.addValue("v\(apiVersion)", forHTTPHeaderField: "Accept-Version")

    let (data, response) = try await urlSession.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
      throw NSError(domain: "GhostingKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
    }

    return data
  }

  /// Fetches posts from the Ghost Content API.
  ///
  /// - Parameters:
  ///   - limit: The maximum number of posts to return (default is 15).
  ///   - page: The page of posts to return (default is 1).
  ///   - include: Related data to include in the response (e.g., "authors,tags").
  ///
  /// - Returns: A `GhostPostsResponse` containing an array of `GhostPost` objects.
  ///
  /// - Throws: An error if the network request fails, returns an invalid response, or fails to decode the JSON.
  public func getPosts(
    limit: Int = 15,
    page: Int = 1,
    include: String? = nil
  ) async throws -> GhostPostsResponse {
    var parameters: [String: String] = [
      "limit": String(limit),
      "page": String(page)
    ]
    if let include = include {
      parameters["include"] = include
    }
    let data = try await get("posts", parameters: parameters)
    let decoder = JSONDecoder()
  //  decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(GhostPostsResponse.self, from: data)
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
    return try decoder.decode(GhostAuthorsResponse.self, from: data)
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
    let response = try decoder.decode(GhostAuthorsResponse.self, from: data)
    guard let author = response.authors.first else {
      throw NSError(domain: "GhostingKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Author not found"])
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
    let response = try decoder.decode(GhostAuthorsResponse.self, from: data)
    guard let author = response.authors.first else {
      throw NSError(domain: "GhostingKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Author not found"])
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
    return try decoder.decode(GhostTagsResponse.self, from: data)
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
    let response = try decoder.decode(GhostTagsResponse.self, from: data)
    return response.tags.first!
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
    let response = try decoder.decode(GhostTagsResponse.self, from: data)
    return response.tags.first!
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
    return try decoder.decode(GhostPagesResponse.self, from: data)
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
    let response = try decoder.decode(GhostPagesResponse.self, from: data)
    return response.pages.first!
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
    let response = try decoder.decode(GhostPagesResponse.self, from: data)
    return response.pages.first!
  }
}
