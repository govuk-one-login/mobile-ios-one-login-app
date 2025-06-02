import Foundation

public enum FeatureFlagsName: String {
    /// Example format :
    /// ```
    /// case enableFeatureFlag = "EnableFeatureFlag"
    /// ```
    
    case enableWalletVisibleViaDeepLink = "walletVisibleViaDeepLink"
    case enableWalletVisibleIfExists = "walletVisibleIfExists"
    case enableWalletVisibleToAll = "walletVisibleToAll"
    case appCheckEnabled = "appCheckEnabled"
}

struct FlagManager {
    private var flagsFromFile = [String: Flaggable]()
    
    /* Should be initialised once only: in AppEnvironment.swift */
    init(flagFileName: String?) {
        guard let jsonPath = Bundle.main.path(forResource: flagFileName, ofType: "json"),
              let jsonData = FileManager.default.contents(atPath: jsonPath) else { return }
        
        do {
            flagsFromFile = try JSONDecoder()
                .decode([Flag].self, from: jsonData)
                .reduce(into: [String: Flaggable]()) { (dictionary, flag) in
                    dictionary[flag.name] = flag
                }
        } catch {
            assertionFailure("Feature flag decoding error: \(error)")
        }
    }
    
    func isEnabled(flagName: FeatureFlagsName) -> Bool? {
        flagsFromFile[flagName.rawValue]?.isEnabled
    }
}

protocol FeatureFlagProvider {
    subscript(_ key: String) -> Any? { get }
}

extension FlagManager: FeatureFlagProvider {
    subscript(key: String) -> Any? {
        guard let key = FeatureFlagsName(rawValue: key) else {
            return nil
        }
        return isEnabled(flagName: key)
    }
}

extension Dictionary: FeatureFlagProvider where Key == String, Value == Any { }

extension UserDefaults: FeatureFlagProvider {
    subscript(key: String) -> Any? {
        object(forKey: key)
    }
}
