import Foundation

/// A structure representing Ghost site settings.
public struct GhostSettings: Codable, Sendable {
    /// The title of the Ghost site.
    public let title: String
    
    /// The description of the Ghost site.
    public let description: String
    
    /// The logo URL for the site.
    public let logo: String?
    
    /// The icon URL for the site.
    public let icon: String?
    
    /// The accent color for the site.
    public let accentColor: String?
    
    /// The cover image URL for the site.
    public let coverImage: String?
    
    /// The Facebook profile URL.
    public let facebook: String?
    
    /// The Twitter profile URL.
    public let twitter: String?
    
    /// The language/locale of the site.
    public let lang: String
    
    /// The timezone of the site.
    public let timezone: String
    
    /// Navigation menu items.
    public let navigation: [NavigationItem]?
    
    /// Secondary navigation menu items.
    public let secondaryNavigation: [NavigationItem]?
    
    /// The URL of the site.
    public let url: String
    
    /// The current version of Ghost.
    public let version: String
    
    /// Meta title for the site.
    public let metaTitle: String?
    
    /// Meta description for the site.
    public let metaDescription: String?
    
    /// Open Graph image URL.
    public let ogImage: String?
    
    /// Open Graph title.
    public let ogTitle: String?
    
    /// Open Graph description.
    public let ogDescription: String?
    
    /// Twitter image URL.
    public let twitterImage: String?
    
    /// Twitter title.
    public let twitterTitle: String?
    
    /// Twitter description.
    public let twitterDescription: String?
    
    /// Whether members are enabled.
    public let membersEnabled: Bool?
    
    /// Whether paid memberships are enabled.
    public let paidMembersEnabled: Bool?
    
    /// Coding keys to map JSON keys to struct properties.
    private enum CodingKeys: String, CodingKey {
        case title, description, logo, icon
        case accentColor = "accent_color"
        case coverImage = "cover_image"
        case facebook, twitter, lang, timezone, navigation
        case secondaryNavigation = "secondary_navigation"
        case url, version
        case metaTitle = "meta_title"
        case metaDescription = "meta_description"
        case ogImage = "og_image"
        case ogTitle = "og_title"
        case ogDescription = "og_description"
        case twitterImage = "twitter_image"
        case twitterTitle = "twitter_title"
        case twitterDescription = "twitter_description"
        case membersEnabled = "members_enabled"
        case paidMembersEnabled = "paid_members_enabled"
    }
}

/// A structure representing a navigation item.
public struct NavigationItem: Codable, Sendable, Identifiable {
    /// A unique identifier for the navigation item.
    public var id: String { label + url }
    
    /// The label/text of the navigation item.
    public let label: String
    
    /// The URL the navigation item points to.
    public let url: String
}

/// A structure representing the response from the Ghost Content API for settings.
public struct GhostSettingsResponse: Decodable, Sendable {
    /// The site settings.
    public let settings: GhostSettings
    
    /// Metadata (if any).
    public let meta: GhostResponseMeta?
    
    /// Coding keys to map JSON keys to struct properties.
    private enum CodingKeys: String, CodingKey {
        case settings
        case meta
    }
}