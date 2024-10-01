import FirebaseAppCheck

protocol AppCheckVendor {
    static func setAppCheckProviderFactory(_ factory: AppCheckProviderFactory?)
    static func appCheck() -> Self

    func token(forcingRefresh: Bool) async throws -> AppCheckToken
}

extension AppCheck: AppCheckVendor { }
