import Foundation
import MobilePlatformServices

public final class AppEnvironment {
    // MARK: - Feature Flags
    
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
    
    private static func isFeatureEnabled(for key: FeatureFlagsName) -> Bool {
        let providers: [FeatureFlagProvider] = [UserDefaults.standard, remoteReleaseFlags, remoteFeatureFlags, localFeatureFlags]
        return providers
            .lazy
            .compactMap { value(for: key.rawValue, provider: $0) }
            .first ?? false
    }
    
    private static func value<T>(for key: String, provider: FeatureFlagProvider) -> T? {
        provider[key] as? T
    }
    
    static var remoteReleaseFlags = ReleaseFlags()
    static var remoteFeatureFlags = FeatureFlags()
    
    private static var localFeatureFlags: FlagManager {
        FlagManager(flagFileName: string(for: .featureFlagFile, in: .configuration))
    }
    
    static func updateFlags(releaseFlags: [String: Bool],
                            featureFlags: [String: Bool]) {
        remoteReleaseFlags.flags = releaseFlags
        remoteFeatureFlags.flags = featureFlags
    }
    
    private static func infoPlistDictionary(name: PlistDictionaryKey) -> [String: String] {
        guard let plist = Bundle.main.infoDictionary,
              let appConfiguration = plist[name.rawValue] as? [String: String] else {
            fatalError("Info.plist doesn't contain a dictionary named '\(name.rawValue)'")
        }
        return appConfiguration
    }
    
    private static func string(for key: PlistRowKey, in dictionary: PlistDictionaryKey) -> String {
        guard let string = infoPlistDictionary(name: dictionary)[key.rawValue] else {
            preconditionFailure("'\(key.rawValue)' not found in Info.plist dictionary '\(dictionary.rawValue)")
        }
        return string
    }
}

// MARK: - Helper properties

extension AppEnvironment {
    static var buildConfiguration: String {
        string(for: .buildConfiguration, in: .configuration)
    }
    
    static var isLocaleWelsh: Bool {
        UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first?.prefix(2) == "cy"
    }
    
    static var localeString: String {
        isLocaleWelsh ? "cy" : "en"
    }
}

// MARK: - STS Info Plist values as Type properties

extension AppEnvironment {
    static var stsClientID: String {
        string(for: .stsClientID, in: .sts)
    }
    
    static var stsBaseURLString: String {
        string(for: .stsBaseURL, in: .sts)
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

// MARK: - Mobile Back End Info Plist values as Type properties

extension AppEnvironment {
    static var mobileBaseURLString: String {
        string(for: .mobileBaseURL, in: .mobileBE)
    }
    
    static var mobileBaseURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = mobileBaseURLString
        return components.url!
    }
    
    static var mobileRedirect: URL {
        mobileBaseURL
            .appendingPathComponent("redirect")
    }
    
    static var appInfoURL: URL {
        mobileBaseURL
            .appendingPathComponent("appInfo")
    }
    
    static var txma: URL {
        mobileBaseURL
            .appendingPathComponent("txma-event")
    }
    
    static var walletCredentialIssuer: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "example-credential-issuer.\(mobileBaseURLString)"
        return components.url!
    }
}

// MARK: - ID Check Info Plist values as Type properties

extension AppEnvironment {
    static var idCheckDomainURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = string(for: .idCheckDomain, in: .idCheck)
        return components.url!
    }
    
    static var idCheckBaseURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = string(for: .idCheckBaseURL, in: .idCheck)
        return components.url!
    }
    
    static var idCheckAsyncBaseURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = string(for: .idCheckAsyncBaseURL, in: .idCheck)
        return components.url!
    }
    
    static var idCheckHandoffURL: URL {
        let url = idCheckDomainURL
            .appendingPathComponent("dca")
            .appendingPathComponent("app")
            .appendingPathComponent("handoff")
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            .init(name: "device", value: "iphone")
        ]
        return components.url!
    }
    
    static var readIDURLString: String {
        string(for: .readIDURL, in: .idCheck)
    }
    
    static var iProovURLString: String {
        string(for: .iProovURL, in: .idCheck)
    }
}

// MARK: - External Info Plist values as Type properties

extension AppEnvironment {
    static var govURLString: String {
        string(for: .govURL, in: .external)
    }
    
    static var yourServicesLink: String {
        string(for: .yourServicesURL, in: .external)
    }
    
    static var externalBaseURLString: String {
        string(for: .externalBaseURL, in: .external)
    }
}

// MARK: - Settings Page URLs
    
extension AppEnvironment {
    
    static var govURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = govURLString
        return components.url!
    }
    
    static var govSupportURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = string(for: .govSupportURL, in: .external)
        return components.url!
    }
    
    static var manageAccountURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = yourServicesLink
        components.path = "/security"
        isLocaleWelsh ? components.query = "lng=\(localeString)" : nil
        return components.url!
    }
    
    static var appHelpURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = govURLString
        components.path = "/guidance/proving-your-identity-with-the-govuk-one-login-app"
        isLocaleWelsh ? components.path.append(".cy") : nil
        return components.url!
    }
    
    static var contactURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = yourServicesLink
        components.path = "/contact-gov-uk-one-login"
        components.query = "lng=\(localeString)"
        return components.url!
    }
    
    static var privacyPolicyURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = govURLString
        components.path = "/government/publications/govuk-one-login-privacy-notice"
        isLocaleWelsh ? components.path.append(".cy") : nil
        return components.url!
    }
    
    static var accessibilityStatementURL: URL {
        var url = govURL
            .appendingPathComponent("one-login")
            .appendingPathComponent("app-accessibility")
        isLocaleWelsh ? url = url.appendingPathComponent("cy") : nil
        return url
    }
}

// MARK: - App Store URL

extension AppEnvironment {
    static var appStoreURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = string(for: .appStoreURL, in: .external)
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
