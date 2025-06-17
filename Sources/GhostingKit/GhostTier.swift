import Foundation

/// A structure representing a Ghost tier (membership tier).
public struct GhostTier: Codable, Sendable, Identifiable, Hashable {
    /// The unique identifier of the tier.
    public let id: String
    
    /// The name of the tier.
    public let name: String
    
    /// The description of the tier.
    public let description: String?
    
    /// The slug of the tier.
    public let slug: String
    
    /// Whether this is an active tier.
    public let active: Bool
    
    /// The type of tier (e.g., "free", "paid").
    public let type: String
    
    /// The welcome page URL for new members.
    public let welcomePageUrl: String?
    
    /// The creation date of the tier.
    public let createdAt: Date
    
    /// The last update date of the tier.
    public let updatedAt: Date
    
    /// The tier visibility.
    public let visibility: String
    
    /// Monthly price in cents.
    public let monthlyPrice: Int?
    
    /// Yearly price in cents.
    public let yearlyPrice: Int?
    
    /// Currency code (e.g., "USD").
    public let currency: String?
    
    /// Trial days for this tier.
    public let trialDays: Int?
    
    /// Benefits of this tier.
    public let benefits: [String]?
    
    /// Coding keys to map JSON keys to struct properties.
    private enum CodingKeys: String, CodingKey {
        case id, name, description, slug, active, type
        case welcomePageUrl = "welcome_page_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case visibility
        case monthlyPrice = "monthly_price"
        case yearlyPrice = "yearly_price"
        case currency
        case trialDays = "trial_days"
        case benefits
    }
}

/// A structure representing the response from the Ghost Content API for tiers.
public struct GhostTiersResponse: Decodable, Sendable {
    /// An array of Ghost tier items.
    public let tiers: [GhostTier]
    
    /// Metadata containing pagination information.
    public let meta: GhostResponseMeta?
    
    /// Coding keys to map JSON keys to struct properties.
    private enum CodingKeys: String, CodingKey {
        case tiers
        case meta
    }
}

extension GhostTiersResponse {
    /// Get pagination information as a helper object
    public var pagination: GhostingKitPagination? {
        if let meta = meta {
            return GhostingKitPagination(from: meta.pagination)
        }
        return nil
    }
}