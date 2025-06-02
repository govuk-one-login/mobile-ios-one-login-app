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
    
    enum PlistDictionaryKey: String {
        case configuration = "Configuration"
        case sts = "STS"
        case mobileBE = "Mobile BE"
        case external = "External"
        case idCheck = "ID Check"
    }
    
    enum PlistRowKey: String {
        case buildConfiguration = "Build Configuration"
        case featureFlagFile = "Feature Flag File"
        case stsBaseURL = "STS Base URL"
        case stsClientID = "STS Client ID"
        case mobileBaseURL = "Mobile BE Base URL"
        case externalBaseURL = "External Base URL"
        case yourServicesURL = "Your Services URL"
        case govURL = "Gov URL"
        case govSupportURL = "Gov Support URL"
        case appStoreURL = "App Store URL"
        case idCheckDomain = "ID Check Domain"
        case idCheckBaseURL = "ID Check Base URL"
        case idCheckAsyncBaseURL = "ID Check Async Base URL"
        case readIDURL = "Read ID URL"
        case iProovURL = "iProov URL"
    }
}
