import Foundation

/// Cache configuration for GhostingKit
public struct GhostingKitCacheConfiguration: Sendable {
    /// Time to live for cached items in seconds
    public let ttl: TimeInterval
    
    /// Maximum number of items to cache
    public let maxItems: Int
    
    /// Whether caching is enabled
    public let isEnabled: Bool
    
    public init(ttl: TimeInterval = 300, maxItems: Int = 100, isEnabled: Bool = true) {
        self.ttl = ttl
        self.maxItems = maxItems
        self.isEnabled = isEnabled
    }
    
    /// Default configuration with 5 minute TTL
    public static let `default` = GhostingKitCacheConfiguration()
    
    /// Disabled cache configuration
    public static let disabled = GhostingKitCacheConfiguration(isEnabled: false)
}

/// Cache key for storing items
internal struct CacheKey: Hashable {
    let endpoint: String
    let parameters: [String: String]
    
    init(endpoint: String, parameters: [String: String]) {
        self.endpoint = endpoint
        self.parameters = parameters
    }
}

/// Cached item with expiration
internal struct CachedItem<T> {
    let value: T
    let expiresAt: Date
    
    var isExpired: Bool {
        Date() > expiresAt
    }
}

/// Thread-safe cache implementation
internal actor GhostingKitCache {
    private var cache: [CacheKey: CachedItem<Data>] = [:]
    private var accessOrder: [CacheKey] = []
    private let configuration: GhostingKitCacheConfiguration
    
    init(configuration: GhostingKitCacheConfiguration) {
        self.configuration = configuration
    }
    
    /// Get cached data if available and not expired
    func get(endpoint: String, parameters: [String: String]) -> Data? {
        guard configuration.isEnabled else { return nil }
        
        let key = CacheKey(endpoint: endpoint, parameters: parameters)
        
        if let cached = cache[key], !cached.isExpired {
            // Move to end for LRU
            if let index = accessOrder.firstIndex(of: key) {
                accessOrder.remove(at: index)
                accessOrder.append(key)
            }
            return cached.value
        } else {
            // Remove expired item
            cache.removeValue(forKey: key)
            if let index = accessOrder.firstIndex(of: key) {
                accessOrder.remove(at: index)
            }
            return nil
        }
    }
    
    /// Store data in cache
    func set(endpoint: String, parameters: [String: String], data: Data) {
        guard configuration.isEnabled else { return }
        
        let key = CacheKey(endpoint: endpoint, parameters: parameters)
        let expiresAt = Date().addingTimeInterval(configuration.ttl)
        
        // Remove if already exists
        if cache[key] != nil, let index = accessOrder.firstIndex(of: key) {
            accessOrder.remove(at: index)
        }
        
        // Add new item
        cache[key] = CachedItem(value: data, expiresAt: expiresAt)
        accessOrder.append(key)
        
        // Enforce max items using LRU
        while accessOrder.count > configuration.maxItems {
            let oldestKey = accessOrder.removeFirst()
            cache.removeValue(forKey: oldestKey)
        }
    }
    
    /// Clear all cached items
    func clear() {
        cache.removeAll()
        accessOrder.removeAll()
    }
    
    /// Remove expired items
    func purgeExpired() {
        let now = Date()
        let expiredKeys = cache.compactMap { key, item in
            item.expiresAt < now ? key : nil
        }
        
        for key in expiredKeys {
            cache.removeValue(forKey: key)
            if let index = accessOrder.firstIndex(of: key) {
                accessOrder.remove(at: index)
            }
        }
    }
}

/// Extension to add caching to GhostingKit
extension GhostingKit {
    /// Configure caching for this GhostingKit instance
    ///
    /// - Parameter configuration: The cache configuration to use
    public func configureCache(_ configuration: GhostingKitCacheConfiguration) async {
        self.setCache(GhostingKitCache(configuration: configuration))
    }
    
    /// Clear all cached data
    public func clearCache() async {
        await cache?.clear()
    }
    
    /// Manually purge expired cache entries
    public func purgeExpiredCache() async {
        await cache?.purgeExpired()
    }
}