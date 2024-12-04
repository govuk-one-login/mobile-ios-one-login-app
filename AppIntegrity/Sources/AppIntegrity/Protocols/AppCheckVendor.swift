import FirebaseAppCheck

/// This protocol is used to initialize a provider depending on the environment it is being used in:
/// - Debug: AppCheckDebugProviderFactory
/// - iOS 14 and above: AppAttestProviderFactory
/// - Below iOS 14: DeviceCheckProviderFactory
///
/// The`token` function is then used to get a token from the provider.
/// The token retrieved is then used in the network call for the client attestation.

protocol AppCheckVendor {
    static func setAppCheckProviderFactory(_ factory: AppCheckProviderFactory?)
    static func appCheck() -> Self

    func token(forcingRefresh: Bool) async throws -> AppCheckToken
}

extension AppCheck: AppCheckVendor { }
