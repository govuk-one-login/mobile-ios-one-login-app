extension AppEnvironment {
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
    
    enum DictionaryKey: String {
        case configuration = "Configuration"
        case sts = "STS"
        case mobileBE = "Mobile BE"
        case external = "External"
    }
    
    enum PlistDictionaryKey: String {
        case buildConfiguration = "Build Configuration"
        case featureFlagFile = "Feature Flag File"
        case stsBaseURL = "STS Base URL"
        case stsClientID = "STS Client ID"
        case mobileBaseURL = "Mobile BE Base URL"
        case externalBaseURL = "External Base URL"
        case yourServicesURL = "Your Services URL"
        case govURL = "Gov URL"
        case appStoreURL = "App Store URL"
    }
}
