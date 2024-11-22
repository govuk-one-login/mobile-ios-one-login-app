import Foundation
import MobilePlatformServices

public final class AppEnvironment {
    enum Key: String {
        case oneLoginAuthorizeURL = "One Login Authorize URL"
        case stsBaseString = "STS Base URL"
        case baseURL = "Base URL"
        case redirectURL = "Redirect URL"
        case oneLoginClientID = "One Login Client ID"
        case stsClientID = "STS Client ID"
        case externalBaseURL = "External Base URL"
        case appStoreURL = "App Store URL"
        case credentialIssuerURL = "Wallet Credential Issuer URL"
        case yourServicesURL = "Your Services URL"
    }
    
    static var releaseFlags = ReleaseFlags()
    static var remoteFeatureFlags = FeatureFlags()
    
    private static var appDictionary: [String: Any] {
        guard let plist = Bundle.main.infoDictionary else {
            fatalError("Cannot load Info.plist from App")
        }
        return plist
    }
    
    private static var localFeatureFlags: FlagManager {
        guard let appConfiguration = appDictionary["Configuration"] as? [String: Any] else {
            fatalError("Info.plist doesn't contain 'Configuration' as [String: Any]")
        }
        return FlagManager(flagFileName: appConfiguration["Feature Flag File"] as? String)
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
    
    static func updateRemoteFlags(_ appInfo: App) {
        releaseFlags.flags = appInfo.releaseFlags
        remoteFeatureFlags.flags = appInfo.featureFlags
    }
}

class ReleaseFlags: FeatureFlagProvider {
    var flags: [String: Bool] = [:]

    subscript(key: String) -> Any? {
        flags[key]
    }
}

class FeatureFlags: FeatureFlagProvider {
    var flags: [String: Bool] = [:]

    subscript(key: String) -> Any? {
        flags[key]
    }
}

// MARK: - One Login Info Plist values as Type properties

extension AppEnvironment {
    static var oneLoginAuthorize: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = string(for: .oneLoginAuthorizeURL)
        components.path = "/authorize"
        return components.url!
    }
    
    static var oneLoginToken: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = string(for: .baseURL)
        components.path = "/token"
        return components.url!
    }

    static var privacyPolicyURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = string(for: .externalBaseURL)
        components.query = "lng=\(isLocaleWelsh ? "cy" : "en")"
        components.path = "/privacy-notice"
        return components.url!
    }
    
    static var manageAccountURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = string(for: .externalBaseURL)
        components.query = "lng=\(isLocaleWelsh ? "cy" : "en")"
        components.path = "/sign-in-or-create"
        return components.url!
    }

    static var oneLoginClientID: String {
        string(for: .oneLoginClientID)
    }
    
    static var oneLoginRedirect: String {
        string(for: .redirectURL)
    }
    
    static var oneLoginBaseURL: String {
        string(for: .baseURL)
    }
    
    static var stsBaseString: String {
        string(for: .stsBaseString)
    }
    
    static var walletCredentialIssuer: String {
        string(for: .credentialIssuerURL)
    }
}

// MARK: - STS Info Plist values as Type properties

extension AppEnvironment {
    static var stsBaseURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = string(for: .stsBaseString)
        return components.url!
    }
    
    static var stsAuthorize: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = string(for: .stsBaseString)
        components.path = "/authorize"
        return components.url!
    }

    static var stsToken: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = string(for: .stsBaseString)
        components.path = "/token"
        return components.url!
    }

    static var stsHelloWorld: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "hello-world.\(string(for: .stsBaseString))"
        components.path = "/hello-world"
        return components.url!
    }
    
    static var jwksURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = string(for: .stsBaseString)
        components.path = "/.well-known/jwks.json"
        return components.url!
    }
    
    static var appInfoURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = string(for: .baseURL)
        components.path = "/appInfo"
        return components.url!
    }
    
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

// MARK: - Feature Flags

extension AppEnvironment {
    static private func isFeatureEnabled(for key: FeatureFlagsName) -> Bool {
        let providers: [FeatureFlagProvider] = [UserDefaults.standard, releaseFlags, remoteFeatureFlags, localFeatureFlags]
        return providers
            .lazy
            .compactMap { value(for: key.rawValue, provider: $0) }
            .first ?? false
    }
    
    static var callingSTSEnabled: Bool {
        isFeatureEnabled(for: .enableCallingSTS)
    }
    
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
}
