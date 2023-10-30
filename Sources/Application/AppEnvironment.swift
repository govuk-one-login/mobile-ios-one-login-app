import Foundation

public final class AppEnvironment {
    enum Key: String {
        case authorizeEndPoint = "Authorize Endpoint"
        case tokenEndpoint = "Token Endpoint"
        case redirectURL = "Redirect URL"
        case clientId = "Client ID"
    }
    
    static var appDictionary: [String: Any] {
        guard let plist = Bundle.main.infoDictionary else {
            fatalError("Cannot load Info.plist from App")
        }
        return plist
    }
    
    static func value<T>(for key: Key) -> T {
        guard let value = appDictionary[key.rawValue] as? T else {
            preconditionFailure("Value not found in Info.plist")
        }
        return value
    }
    
    static func string(for key: Key) -> String {
        guard let string: String = value(for: key) else {
            preconditionFailure("Key not found in Info.plist")
        }
        return string
    }
}
