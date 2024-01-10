import Foundation

public final class AppEnvironment {
    enum Key: String {
        case authorizeURL = "Authorize URL"
        case baseURL = "Base URL"
        case redirectURL = "Redirect URL"
        case clientID = "Client ID"
    }
    
    private static var appDictionary: [String: Any] {
        guard let plist = Bundle.main.infoDictionary else {
            fatalError("Cannot load Info.plist from App")
        }
        return plist
    }
    
    private static var featureFlags: FlagManager {
        guard let appConfiguration = appDictionary["Configuration"] as? [String: Any] else {
            fatalError("Info.plist doesn't contain 'Configuration' as [String: Any]")
        }
        return FlagManager(flagFileName: appConfiguration["Feature Flag File"] as? String)
    }
    
    private static func value<T>(for key: String, provider: EnvironmentProvider) -> T? {
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

// MARK: - Info Plist values as Type properties

extension AppEnvironment {
    static var oneLoginAuthorize: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = string(for: .authorizeURL)
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
    
    static var oneLoginClientID: String {
        return string(for: .clientID)
    }
    
    static var oneLoginRedirect: String {
        return string(for: .redirectURL)
    }
}

// MARK: - Feature Flags

 extension AppEnvironment {
     static private func isFeatureEnabled(for key: FeatureFlags) -> Bool {
         let providers: [EnvironmentProvider] = [appDictionary, UserDefaults.standard]
         return providers
             .lazy
             .compactMap { value(for: key.rawValue, provider: $0) }
             .first ?? false
     }
     
     static var callingSTSEnabled: Bool {
         isFeatureEnabled(for: .enableCallingSTS)
    }
 }
