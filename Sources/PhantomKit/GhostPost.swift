//
//  GhostPost.swift
//  PhantomKit
//
//  Created by Rudrank Riyam on 10/16/24.
//

import Foundation

/// A structure representing a Ghost blog post.
///
/// This structure is designed to be `Codable`, allowing for easy decoding of JSON data
/// returned by the Ghost Content API for posts. It includes various properties that
/// describe the content and metadata of a blog post.
public struct GhostPost: Codable, Sendable {
  /// The URL slug of the post.
  public let slug: String
  
  /// The unique identifier of the post.
  public let id: String
  
  /// The UUID of the post.
  public let uuid: String
  
  /// The title of the post.
  public let title: String
  
  /// The HTML content of the post.
  public let html: String
  
  /// The comment ID associated with the post.
  public let commentId: String
  
  /// The URL of the feature image for the post.
  public let featureImage: String?
  
  /// The alt text for the feature image.
  public let featureImageAlt: String?
  
  /// The caption for the feature image.
  public let featureImageCaption: String?
  
  /// Indicates whether the post is featured.
  public let featured: Bool
  
  /// The visibility status of the post.
  public let visibility: String
  
  /// The creation date of the post.
  public let createdAt: String
  
  /// The last update date of the post.
  public let updatedAt: String
  
  /// The publication date of the post.
  public let publishedAt: String
  
  /// A custom excerpt for the post.
  public let customExcerpt: String?
  
  /// Custom code to be injected into the head of the post.
  public let codeinjectionHead: String?
  
  /// Custom code to be injected into the foot of the post.
  public let codeinjectionFoot: String?
  
  /// The name of a custom template used for the post.
  public let customTemplate: String?
  
  /// The canonical URL of the post.
  public let canonicalUrl: String?
  
  /// The URL of the post.
  public let url: String
  
  /// An excerpt of the post content.
  public let excerpt: String
  
  /// The estimated reading time of the post in minutes.
  public let readingTime: Int
  
  /// Indicates whether the post is accessible.
  public let access: Bool
  
  /// The Open Graph image URL for the post.
  public let ogImage: String?
  
  /// The Open Graph title for the post.
  public let ogTitle: String?
  
  /// The Open Graph description for the post.
  public let ogDescription: String?
  
  /// The Twitter image URL for the post.
  public let twitterImage: String?
  
  /// The Twitter title for the post.
  public let twitterTitle: String?
  
  /// The Twitter description for the post.
  public let twitterDescription: String?
  
  /// The meta title for the post.
  public let metaTitle: String?
  
  /// The meta description for the post.
  public let metaDescription: String?
  
  /// The email subject for the post.
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
public struct GhostPostsResponse: Codable, Sendable {
  /// An array of Ghost blog posts.
  public let posts: [GhostPost]
}
