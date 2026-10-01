import AppIntegrity
import FirebaseAppCheck

public final class MockAppCheckVendor: AppCheckVendor {
    public private(set) static var wasConfigured: (any AppCheckProviderFactory)?
    public var errorFromLimitedUseToken: Error?

    public static func setAppCheckProviderFactory(_ factory: (any AppCheckProviderFactory)?) {
        self.wasConfigured = factory
    }
    
    public static func appCheck() -> Self {
        guard let vendor = MockAppCheckVendor() as? Self else {
            preconditionFailure("Expected MockAppCheckVendor to conform to AppCheckVendor")
        }
        return vendor
    }
    
    public init(errorFromLimitedUseToken: Error? = nil) {
        self.errorFromLimitedUseToken = errorFromLimitedUseToken
    }
    
    public func limitedUseToken() async throws -> AppCheckToken {
        if let errorFromLimitedUseToken {
            throw errorFromLimitedUseToken
        }
        return AppCheckToken(token: "abc", expirationDate: .distantFuture)
    }
}
