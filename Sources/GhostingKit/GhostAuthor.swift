import Foundation

/// Represents an author in the Ghost Content API.
///
/// Authors are a subset of users who have published posts associated with them.
public struct GhostAuthor: Codable, Sendable, Identifiable, Hashable, Equatable {
  /// The unique identifier of the author.
  public let id: String
  
  /// The slug of the author, used in URLs.
  public let slug: String
  
  /// The name of the author.
  public let name: String
  
  /// The URL of the author's profile image.
  public let profileImage: String?
  
  /// The URL of the author's cover image.
  public let coverImage: String?
  
  /// The biography of the author.
  public let bio: String?
  
  /// The website URL of the author.
  public let website: String?
  
  /// The location of the author.
  public let location: String?
  
  /// The Facebook username of the author.
  public let facebook: String?
  
  /// The Twitter handle of the author.
  public let twitter: String?
  
  /// The meta title for SEO purposes.
  public let metaTitle: String?
  
  /// The meta description for SEO purposes.
  public let metaDescription: String?
  
  /// The full URL of the author's page on the Ghost site.
  public let url: String
  
  /// The number of posts associated with the author.
  public let count: PostCount?
  
  /// Represents the count of posts for an author.
  public struct PostCount: Codable, Sendable, Hashable, Equatable {
    /// The number of posts associated with the author.
    public let posts: Int
  }
  
  enum CodingKeys: String, CodingKey {
    case id, slug, name, bio, website, location, facebook, twitter, url
    case profileImage = "profile_image"
    case coverImage = "cover_image"
    case metaTitle = "meta_title"
    case metaDescription = "meta_description"
    case count
  }
}

/// Represents the response structure for author requests.
public struct GhostAuthorsResponse: Codable, Sendable {
  /// An array of authors returned by the API.
  public let authors: [GhostAuthor]
  
  /// Metadata containing pagination information.
  public let meta: GhostResponseMeta?
}
