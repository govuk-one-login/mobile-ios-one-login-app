import Foundation

public enum FeatureFlags: String {
    /// Example format :
    /// ```
    /// case enableFeatureFlag = "EnableFeatureFlag"
    /// ```
    
    case enableCallingSTS = "EnableCallingSTS"
}

struct FlagManager {
    private(set) var flagsFromFile = [String: Flaggable]()
    
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
    
    func isEnabled(flagName: FeatureFlags) -> Bool? {
        flagsFromFile[flagName.rawValue]?.isEnabled
    }
}

protocol FeatureFlagProvider {
    subscript(_ key: String) -> Any? { get }
}

extension FlagManager: FeatureFlagProvider {
    subscript(key: String) -> Any? {
        guard let key = FeatureFlags(rawValue: key) else {
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
