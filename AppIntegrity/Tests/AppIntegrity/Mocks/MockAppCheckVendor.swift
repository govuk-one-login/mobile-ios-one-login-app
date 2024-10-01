@testable import AppIntegrity
import FirebaseAppCheck

final class MockAppCheckVendor: AppCheckVendor {
    static func setAppCheckProviderFactory(_ factory: (any AppCheckProviderFactory)?) {

    }
    
    static func appCheck() -> Self {
        guard let vendor = MockAppCheckVendor() as? Self else {
            preconditionFailure("Expected MockAppCheckVendor to conform to AppCheckVendor")
        }
        return vendor
    }
    
    func token(forcingRefresh: Bool) async throws -> AppCheckToken {
        AppCheckToken(token: "abc", expirationDate: .distantFuture)
    }
}
