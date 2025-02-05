@testable import AppIntegrity
import FirebaseAppCheck

final class MockAppCheckVendor: AppCheckVendor {
    private(set) static var wasConfigured: (any AppCheckProviderFactory)?

    static func setAppCheckProviderFactory(_ factory: (any AppCheckProviderFactory)?) {
        self.wasConfigured = factory
    }
    
    static func appCheck() -> Self {
        guard let vendor = MockAppCheckVendor() as? Self else {
            preconditionFailure("Expected MockAppCheckVendor to conform to AppCheckVendor")
        }
        return vendor
    }
    
    func limitedUseToken() async throws -> AppCheckToken {
        AppCheckToken(token: "abc", expirationDate: .distantFuture)
    }
}
