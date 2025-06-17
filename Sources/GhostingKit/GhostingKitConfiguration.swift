import Foundation

/// Configuration helper for GhostingKit
public struct GhostingKitConfiguration {
    /// The admin domain for the Ghost site
    public let adminDomain: String
    
    /// The API key for authentication
    public let apiKey: String
    
    /// The API version to use
    public let apiVersion: String
    
    /// The cache configuration
    public let cacheConfiguration: GhostingKitCacheConfiguration
    
    /// The retry configuration
    public let retryConfiguration: GhostingKitRetryConfiguration
    
    public init(
        adminDomain: String,
        apiKey: String,
        apiVersion: String = "v5.0",
        cacheConfiguration: GhostingKitCacheConfiguration = .default,
        retryConfiguration: GhostingKitRetryConfiguration = .default
    ) {
        self.adminDomain = adminDomain
        self.apiKey = apiKey
        self.apiVersion = apiVersion
        self.cacheConfiguration = cacheConfiguration
        self.retryConfiguration = retryConfiguration
    }
}

/// Secure configuration loading utilities
public extension GhostingKitConfiguration {
    /// Load configuration from Bundle Info.plist
    ///
    /// Add these keys to your Info.plist:
    /// - GhostAdminDomain: Your Ghost site domain
    /// - GhostAPIKey: Your Ghost Content API key
    ///
    /// - Parameter bundle: The bundle to read from (defaults to main bundle)
    /// - Returns: A configuration object loaded from the bundle
    /// - Throws: GhostingKitError if required keys are missing
    static func fromBundle(_ bundle: Bundle = .main) throws -> GhostingKitConfiguration {
        guard let adminDomain = bundle.object(forInfoDictionaryKey: "GhostAdminDomain") as? String,
              !adminDomain.isEmpty else {
            throw GhostingKitError.invalidAdminDomain("Missing GhostAdminDomain in Info.plist")
        }
        
        guard let apiKey = bundle.object(forInfoDictionaryKey: "GhostAPIKey") as? String,
              !apiKey.isEmpty else {
            throw GhostingKitError.invalidAPIKey
        }
        
        let apiVersion = bundle.object(forInfoDictionaryKey: "GhostAPIVersion") as? String ?? "v5.0"
        
        return GhostingKitConfiguration(
            adminDomain: adminDomain,
            apiKey: apiKey,
            apiVersion: apiVersion
        )
    }
    
    /// Load configuration from environment variables
    ///
    /// Expected environment variables:
    /// - GHOST_ADMIN_DOMAIN: Your Ghost site domain
    /// - GHOST_API_KEY: Your Ghost Content API key
    /// - GHOST_API_VERSION: API version (optional, defaults to v5.0)
    ///
    /// - Returns: A configuration object loaded from environment variables
    /// - Throws: GhostingKitError if required variables are missing
    static func fromEnvironment() throws -> GhostingKitConfiguration {
        guard let adminDomain = ProcessInfo.processInfo.environment["GHOST_ADMIN_DOMAIN"],
              !adminDomain.isEmpty else {
            throw GhostingKitError.invalidAdminDomain("Missing GHOST_ADMIN_DOMAIN environment variable")
        }
        
        guard let apiKey = ProcessInfo.processInfo.environment["GHOST_API_KEY"],
              !apiKey.isEmpty else {
            throw GhostingKitError.invalidAPIKey
        }
        
        let apiVersion = ProcessInfo.processInfo.environment["GHOST_API_VERSION"] ?? "v5.0"
        
        return GhostingKitConfiguration(
            adminDomain: adminDomain,
            apiKey: apiKey,
            apiVersion: apiVersion
        )
    }
    
    /// Load configuration from a JSON file
    ///
    /// Expected JSON format:
    /// ```json
    /// {
    ///   "adminDomain": "your-site.ghost.io",
    ///   "apiKey": "your-api-key",
    ///   "apiVersion": "v5.0"
    /// }
    /// ```
    ///
    /// - Parameter url: The URL to the JSON configuration file
    /// - Returns: A configuration object loaded from the JSON file
    /// - Throws: Errors related to file reading or JSON decoding
    static func fromJSON(at url: URL) throws -> GhostingKitConfiguration {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        
        struct JSONConfiguration: Codable {
            let adminDomain: String
            let apiKey: String
            let apiVersion: String?
        }
        
        let jsonConfig = try decoder.decode(JSONConfiguration.self, from: data)
        
        return GhostingKitConfiguration(
            adminDomain: jsonConfig.adminDomain,
            apiKey: jsonConfig.apiKey,
            apiVersion: jsonConfig.apiVersion ?? "v5.0"
        )
    }
}

/// Convenience initializer for GhostingKit using configuration
public extension GhostingKit {
    /// Initialize GhostingKit with a configuration object
    ///
    /// - Parameter configuration: The configuration to use
    /// - Throws: GhostingKitError if the configuration is invalid
    static func create(configuration: GhostingKitConfiguration) async throws -> GhostingKit {
        let ghostingKit = try GhostingKit(
            adminDomain: configuration.adminDomain,
            apiKey: configuration.apiKey,
            apiVersion: configuration.apiVersion,
            retryConfiguration: configuration.retryConfiguration
        )
        await ghostingKit.configureCache(configuration.cacheConfiguration)
        return ghostingKit
    }
}