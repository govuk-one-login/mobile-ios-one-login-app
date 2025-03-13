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
    
    enum Key: String {
        case stsBaseURL = "STS Base URL"
        case mobileBaseURL = "Mobile BE Base URL"
        case externalBaseURL = "External Base URL"
        case stsClientID = "STS Client ID"
        case appStoreURL = "App Store URL"
        case yourServicesURL = "Your Services URL"
        case govURLString = "Gov URL"
        case buildConfiguration = "Build Configuration"
    }
}
