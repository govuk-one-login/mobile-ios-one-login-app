import FirebaseAppCheck
@testable import AppIntegrity

final class MockAppCheckVendor: AppCheckVendor {
    static func setAppCheckProviderFactory(_ factory: (any AppCheckProviderFactory)?) {

    }
    
    static func appCheck() -> Self {
        MockAppCheckVendor() as! Self
    }
    
    func token(forcingRefresh: Bool) async throws -> AppCheckToken {
        AppCheckToken(token: "abc", expirationDate: .distantFuture)
    }
}
