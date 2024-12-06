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
    
    static var mobileRedirect: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = mobileBaseURLString
        components.path = "/redirect"
        return components.url!
    }
    
    static var walletCredentialIssuer: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "example-credential-issuer.\(mobileBaseURLString)"
        return components.url!
    }
    
    static var appInfoURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = mobileBaseURLString
        components.path = "/appInfo"
        return components.url!
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
        var components = URLComponents()
        components.scheme = "https"
        components.host = stsBaseURLString
        components.path = "/authorize"
        return components.url!
    }
    
    static var stsToken: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = stsBaseURLString
        components.path = "/token"
        return components.url!
    }
    
    static var stsHelloWorld: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "hello-world.\(stsBaseURLString)"
        components.path = "/hello-world"
        return components.url!
    }
    
    static var jwksURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = stsBaseURLString
        components.path = "/.well-known/jwks.json"
        return components.url!
    }
}

// MARK: - External Info Plist values as Type properties

extension AppEnvironment {
    static var externalBaseURLString: String {
        string(for: .externalBaseURL)
    }
    
    static var privacyPolicyURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = externalBaseURLString
        components.query = "lng=\(isLocaleWelsh ? "cy" : "en")"
        components.path = "/privacy-notice"
        return components.url!
    }
    
    static var manageAccountURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = externalBaseURLString
        components.query = "lng=\(isLocaleWelsh ? "cy" : "en")"
        components.path = "/sign-in-or-create"
        return components.url!
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

// MARK: - Content tile URLs

extension AppEnvironment {
    static var yourServicesURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = string(for: .yourServicesURL)
        components.query = "lng=\(isLocaleWelsh ? "cy" : "en")"
        components.path = "/your-services"
        return components.url!
    }
    
    static var yourServicesLink: String {
        string(for: .yourServicesURL)
    }
}
