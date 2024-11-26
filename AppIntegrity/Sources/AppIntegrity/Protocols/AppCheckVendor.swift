import FirebaseAppCheck

protocol AppCheckVendor {
    static func setAppCheckProviderFactory(_ factory: AppCheckProviderFactory?)
    static func appCheck() -> Self

    func limitedUseToken() async throws -> AppCheckToken
}

extension AppCheck: AppCheckVendor { }
