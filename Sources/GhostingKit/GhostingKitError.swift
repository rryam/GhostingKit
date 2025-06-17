import Foundation

/// Errors that can occur when using GhostingKit.
public enum GhostingKitError: LocalizedError {
    /// Invalid URL components or configuration
    case invalidURL(String)
    
    /// Network request failed with HTTP status code
    case httpError(statusCode: Int, message: String?)
    
    /// Failed to decode the response
    case decodingError(Error)
    
    /// The requested resource was not found
    case resourceNotFound(type: String, identifier: String)
    
    /// Invalid admin domain format
    case invalidAdminDomain(String)
    
    /// API key is missing or invalid
    case invalidAPIKey
    
    /// Network connectivity error
    case networkError(Error)
    
    /// Request timed out
    case timeout
    
    /// Request was cancelled
    case cancelled
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .httpError(let statusCode, let message):
            if let message = message {
                return "HTTP Error \(statusCode): \(message)"
            }
            return "HTTP Error \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .resourceNotFound(let type, let identifier):
            return "\(type) not found with identifier: \(identifier)"
        case .invalidAdminDomain(let domain):
            return "Invalid admin domain: \(domain). Expected format: example.ghost.io"
        case .invalidAPIKey:
            return "Invalid or missing API key"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .timeout:
            return "Request timed out"
        case .cancelled:
            return "Request was cancelled"
        }
    }
}

/// Configuration for retry behavior
public struct GhostingKitRetryConfiguration: Sendable {
    /// Maximum number of retry attempts
    public let maxAttempts: Int
    
    /// Base delay between retries in seconds
    public let baseDelay: TimeInterval
    
    /// Whether to use exponential backoff
    public let useExponentialBackoff: Bool
    
    /// Maximum delay between retries
    public let maxDelay: TimeInterval
    
    /// HTTP status codes that should trigger a retry
    public let retryableStatusCodes: Set<Int>
    
    public init(
        maxAttempts: Int = 3,
        baseDelay: TimeInterval = 1.0,
        useExponentialBackoff: Bool = true,
        maxDelay: TimeInterval = 60.0,
        retryableStatusCodes: Set<Int> = [408, 429, 500, 502, 503, 504]
    ) {
        self.maxAttempts = max(1, maxAttempts)
        self.baseDelay = max(0.1, baseDelay)
        self.useExponentialBackoff = useExponentialBackoff
        self.maxDelay = max(baseDelay, maxDelay)
        self.retryableStatusCodes = retryableStatusCodes
    }
    
    /// Default retry configuration
    public static let `default` = GhostingKitRetryConfiguration()
    
    /// No retry configuration
    public static let disabled = GhostingKitRetryConfiguration(maxAttempts: 1)
    
    /// Calculate delay for a given attempt
    internal func delay(for attempt: Int) -> TimeInterval {
        guard attempt > 0 else { return 0 }
        
        if useExponentialBackoff {
            let exponentialDelay = baseDelay * pow(2.0, Double(attempt - 1))
            return min(exponentialDelay, maxDelay)
        } else {
            return baseDelay
        }
    }
}