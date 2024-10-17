//
//  GhostPost.swift
//  PhantomKit
//
//  Created by Rudrank Riyam on 10/16/24.
//

import Foundation

/// A generic structure representing a Ghost content item (post or page).
public struct GhostContent: Codable, Sendable {
  /// The URL slug of the content item.
  public let slug: String
  
  /// The unique identifier of the content item.
  public let id: String
  
  /// The UUID of the content item.
  public let uuid: String
  
  /// The title of the content item.
  public let title: String
  
  /// The HTML content of the content item.
  public let html: String
  
  /// The comment ID associated with the content item.
  public let commentId: String
  
  /// The URL of the feature image for the content item.
  public let featureImage: String?
  
  /// The alt text for the feature image.
  public let featureImageAlt: String?
  
  /// The caption for the feature image.
  public let featureImageCaption: String?
  
  /// Indicates whether the content item is featured.
  public let featured: Bool
  
  /// The visibility status of the content item.
  public let visibility: String
  
  /// The creation date of the content item.
  public let createdAt: String
  
  /// The last update date of the content item.
  public let updatedAt: String
  
  /// The publication date of the content item.
  public let publishedAt: String
  
  /// A custom excerpt for the content item.
  public let customExcerpt: String?
  
  /// Custom code to be injected into the head of the content item.
  public let codeinjectionHead: String?
  
  /// Custom code to be injected into the foot of the content item.
  public let codeinjectionFoot: String?
  
  /// The name of a custom template used for the content item.
  public let customTemplate: String?
  
  /// The canonical URL of the content item.
  public let canonicalUrl: String?
  
  /// The URL of the content item.
  public let url: String
  
  /// An excerpt of the content item's content.
  public let excerpt: String
  
  /// The estimated reading time of the content item in minutes.
  public let readingTime: Int
  
  /// Indicates whether the content item is accessible.
  public let access: Bool
  
  /// The Open Graph image URL for the content item.
  public let ogImage: String?
  
  /// The Open Graph title for the content item.
  public let ogTitle: String?
  
  /// The Open Graph description for the content item.
  public let ogDescription: String?
  
  /// The Twitter image URL for the content item.
  public let twitterImage: String?
  
  /// The Twitter title for the content item.
  public let twitterTitle: String?
  
  /// The Twitter description for the content item.
  public let twitterDescription: String?
  
  /// The meta title for the content item.
  public let metaTitle: String?
  
  /// The meta description for the content item.
  public let metaDescription: String?
  
  /// The email subject for the content item.
  public let emailSubject: String?
  
  /// Coding keys to map JSON keys to struct properties.
  private enum CodingKeys: String, CodingKey {
    case slug, id, uuid, title, html
    case commentId = "comment_id"
    case featureImage = "feature_image"
    case featureImageAlt = "feature_image_alt"
    case featureImageCaption = "feature_image_caption"
    case featured, visibility
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case publishedAt = "published_at"
    case customExcerpt = "custom_excerpt"
    case codeinjectionHead = "codeinjection_head"
    case codeinjectionFoot = "codeinjection_foot"
    case customTemplate = "custom_template"
    case canonicalUrl = "canonical_url"
    case url, excerpt
    case readingTime = "reading_time"
    case access
    case ogImage = "og_image"
    case ogTitle = "og_title"
    case ogDescription = "og_description"
    case twitterImage = "twitter_image"
    case twitterTitle = "twitter_title"
    case twitterDescription = "twitter_description"
    case metaTitle = "meta_title"
    case metaDescription = "meta_description"
    case emailSubject = "email_subject"
  }
}

/// A structure representing the response from the Ghost Content API for posts.
public struct GhostPostsResponse: Decodable, Sendable {
  /// An array of Ghost post items.
  public let posts: [GhostContent]

  /// Metadata containing pagination information.
  public let meta: GhostResponseMeta?

  /// Coding keys to map JSON keys to struct properties.
  private enum CodingKeys: String, CodingKey {
    case posts
    case meta
  }
}

/// A structure representing the response from the Ghost Content API for pages.
public struct GhostPagesResponse: Decodable, Sendable {
  /// An array of Ghost page items.
  public let pages: [GhostContent]

  /// Metadata containing pagination information.
  public let meta: GhostResponseMeta?

  /// Coding keys to map JSON keys to struct properties.
  private enum CodingKeys: String, CodingKey {
    case pages
    case meta
  }
}

/// A structure representing the metadata in the Ghost Content API response.
public struct GhostResponseMeta: Codable, Sendable {
  /// The total number of items available.
  public let pagination: GhostPagination
}

/// A structure representing the pagination information in the Ghost Content API response.
public struct GhostPagination: Codable, Sendable {
  /// The current page number.
  public let page: Int
  
  /// The number of items per page.
  public let limit: Int
  
  /// The total number of pages available.
  public let pages: Int
  
  /// The total number of items available.
  public let total: Int
}
