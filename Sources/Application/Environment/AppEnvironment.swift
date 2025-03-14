import Foundation
import MobilePlatformServices

public final class AppEnvironment {
    // MARK: - Feature Flags
    
    static var signoutErrorEnabled: Bool {
        isFeatureEnabled(for: .enableSignoutError)
    }
    
    static var clearWalletErrorEnabled: Bool {
        isFeatureEnabled(for: .enableClearWalletError)
    }
    
    static var walletVisibleViaDeepLink: Bool {
        isFeatureEnabled(for: .enableWalletVisibleViaDeepLink)
    }
    
    static var walletVisibleIfExists: Bool {
        isFeatureEnabled(for: .enableWalletVisibleIfExists)
    }
    
    static var walletVisibleToAll: Bool {
        isFeatureEnabled(for: .enableWalletVisibleToAll)
    }
    
    static var criOrchestratorEnabled: Bool {
        isFeatureEnabled(for: .enableCRIOrchestrator)
    }
    
    static var appIntegrityEnabled: Bool {
        isFeatureEnabled(for: .appCheckEnabled)
    }
    
    static private func isFeatureEnabled(for key: FeatureFlagsName) -> Bool {
        let providers: [FeatureFlagProvider] = [UserDefaults.standard, remoteReleaseFlags, remoteFeatureFlags, localFeatureFlags]
        return providers
            .lazy
            .compactMap { value(for: key.rawValue, provider: $0) }
            .first ?? false
    }
    
    static var remoteReleaseFlags = ReleaseFlags()
    static var remoteFeatureFlags = FeatureFlags()
    
    private static var localFeatureFlags: FlagManager {
        guard let appConfiguration = appDictionary["Configuration"] as? [String: Any] else {
            fatalError("Info.plist doesn't contain 'Configuration' as [String: Any]")
        }
        return FlagManager(flagFileName: appConfiguration["Feature Flag File"] as? String)
    }
    
    static func updateFlags(releaseFlags: [String: Bool],
                            featureFlags: [String: Bool]) {
        remoteReleaseFlags.flags = releaseFlags
        remoteFeatureFlags.flags = featureFlags
    }
    
    private static var appDictionary: [String: Any] {
        guard let plist = Bundle.main.infoDictionary else {
            fatalError("Cannot load Info.plist from App")
        }
        return plist
    }
    
    static func value<T>(for key: String, provider: FeatureFlagProvider) -> T? {
        provider[key] as? T
    }
    
    private static func value<T>(for key: String) -> T {
        guard let value = appDictionary[key] as? T else {
            preconditionFailure("Value not found in Info.plist")
        }
        return value
    }
    
    private static func string(for key: Key) -> String {
        guard let string: String = value(for: key.rawValue) else {
            preconditionFailure("Key not found in Info.plist")
        }
        return string
    }
    
    static var buildConfiguration: String {
        string(for: .buildConfiguration)
    }
    
    static var localeString: String {
        isLocaleWelsh ? "cy" : "en"
    }
}

// MARK: - Mobile Back End Info Plist values as Type properties

extension AppEnvironment {
    static var mobileBaseURLString: String {
        string(for: .mobileBaseURL)
    }
    
    static var mobileBaseURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = mobileBaseURLString
        return components.url!
    }
    
    static var txma: URL {
        mobileBaseURL
            .appendingPathComponent("txma-event")
    }
    
    static var mobileRedirect: URL {
        mobileBaseURL
            .appendingPathComponent("redirect")
    }
    
    static var walletCredentialIssuer: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "example-credential-issuer.\(mobileBaseURLString)"
        return components.url!
    }
    
    static var appInfoURL: URL {
        mobileBaseURL
            .appendingPathComponent("appInfo")
    }
}

// MARK: - STS Info Plist values as Type properties

extension AppEnvironment {
    static var stsBaseURLString: String {
        string(for: .stsBaseURL)
    }
    
    static var stsBaseURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = stsBaseURLString
        return components.url!
    }
    
    static var stsAuthorize: URL {
        stsBaseURL
            .appendingPathComponent("authorize")
    }
    
    static var stsToken: URL {
        stsBaseURL
            .appendingPathComponent("token")
    }
    
    static var stsHelloWorld: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "hello-world.\(stsBaseURLString)"
        components.path = "/hello-world"
        return components.url!
    }
    
    static var jwksURL: URL {
        stsBaseURL
            .appendingPathComponent(".well-known")
            .appendingPathComponent("jwks.json")
    }
}

// MARK: - External Info Plist values as Type properties

extension AppEnvironment {
    static var externalBaseURLString: String {
        string(for: .externalBaseURL)
    }
    
    static var govURLString: String {
        string(for: .govURLString)
    }
    
    static var yourServicesLink: String {
        string(for: .yourServicesURL)
    }
}

// MARK: - Settings Page URLs
    
extension AppEnvironment {
    static var manageAccountURL: URL {
        isLocaleWelsh ? manageAccountURLWelsh : manageAccountURLEnglish
    }
    
    static var govURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = govURLString
        return components.url!
    }
    
    static var manageAccountURLEnglish: URL {
        govURL
            .appendingPathComponent("using-your-gov-uk-one-login")
    }

    private static var manageAccountURLWelsh: URL {
        govURL
            .appendingPathComponent("defnyddio-eich-gov-uk-one-login")
    }
    
    static var appHelpURL: URL {
        govURL
            .appendingPathComponent("one-login")
            .appendingPathComponent("app-help?lng=\(localeString)")
    }
    
    static var contactURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = yourServicesLink
        components.path = "/contact-gov-uk-one-login"
        components.query = "lng=\(localeString)"
        return components.url!
    }
    
    static var externalBaseURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = externalBaseURLString
        return components.url!
    }
    
    static var privacyPolicyURL: URL {
        externalBaseURL
            .appendingPathComponent("privacy-notice?lng=\(localeString)")
    }
    
    static var accessibilityStatementURL: URL {
        externalBaseURL
            .appendingPathComponent("accessibility-statement?lng=\(localeString)")
    }
}

// MARK: - Client ID as Strings

extension AppEnvironment {
    static var stsClientID: String {
        return string(for: .stsClientID)
    }
    
    static var isLocaleWelsh: Bool {
        UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first?.prefix(2) == "cy"
    }
}

// MARK: - App Store URL

extension AppEnvironment {
    static var appStoreURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = string(for: .appStoreURL)
        return components.url!
    }
    
    static var appStore: URL {
        appStoreURL
            .appendingPathComponent("gb")
            .appendingPathExtension("app")
            .appendingPathExtension("uk.gov.digital-identity")
        // TODO: DCMAW-9819: Update to App ID
    }
}
