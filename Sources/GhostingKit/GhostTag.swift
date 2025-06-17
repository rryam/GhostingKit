//
//  GhostTag.swift
//  PhantomKit
//
//  Created by Rudrank Riyam on 10/17/24.
//

import Foundation

/// A struct representing a tag in the Ghost Content API.
public struct GhostTag: Codable, Sendable, Identifiable, Hashable, Equatable {
  /// The unique identifier of the tag.
  public let id: String

  /// The slug of the tag, used in URLs.
  public let slug: String

  /// The name of the tag.
  public let name: String

  /// An optional description of the tag.
  public let description: String?

  /// An optional URL for the tag's feature image.
  public let featureImage: String?

  /// The visibility of the tag (e.g., "public" or "internal").
  public let visibility: String

  /// An optional meta title for SEO purposes.
  public let metaTitle: String?

  /// An optional meta description for SEO purposes.
  public let metaDescription: String?

  /// An optional Open Graph image URL.
  public let ogImage: String?

  /// An optional Open Graph title.
  public let ogTitle: String?

  /// An optional Open Graph description.
  public let ogDescription: String?

  /// An optional Twitter image URL.
  public let twitterImage: String?

  /// An optional Twitter title.
  public let twitterTitle: String?

  /// An optional Twitter description.
  public let twitterDescription: String?

  /// Optional custom code to be injected into the <head> of the tag page.
  public let codeinjectionHead: String?

  /// Optional custom code to be injected into the footer of the tag page.
  public let codeinjectionFoot: String?

  /// An optional canonical URL for the tag.
  public let canonicalUrl: String?

  /// An optional accent color for the tag.
  public let accentColor: String?

  /// The URL of the tag page on the Ghost site.
  public let url: String

  /// The number of posts associated with this tag (only present if requested with include=count.posts).
  public let count: TagCount?

  private enum CodingKeys: String, CodingKey {
    case id, slug, name, description, visibility, url, count
    case featureImage = "feature_image"
    case metaTitle = "meta_title"
    case metaDescription = "meta_description"
    case ogImage = "og_image"
    case ogTitle = "og_title"
    case ogDescription = "og_description"
    case twitterImage = "twitter_image"
    case twitterTitle = "twitter_title"
    case twitterDescription = "twitter_description"
    case codeinjectionHead = "codeinjection_head"
    case codeinjectionFoot = "codeinjection_foot"
    case canonicalUrl = "canonical_url"
    case accentColor = "accent_color"
  }
}

/// A struct representing the count of posts for a tag.
public struct TagCount: Codable, Sendable, Hashable, Equatable {
  /// The number of posts associated with the tag.
  public let posts: Int
}

/// A struct representing the response from the Ghost Content API for tag requests.
public struct GhostTagsResponse: Codable, Sendable {
  /// An array of tags returned by the API.
  public let tags: [GhostTag]
  
  /// Metadata containing pagination information.
  public let meta: GhostResponseMeta?
}