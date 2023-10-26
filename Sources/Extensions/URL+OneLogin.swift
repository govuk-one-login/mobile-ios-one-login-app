import Foundation

extension URL {
    static var oneLoginAuthorize: URL {
        guard let authorizeEndpoint = Bundle.main.infoDictionary?["Authorize Endpoint"] as? String else {
            fatalError("Couldn't fetch Authorize Endpoint from plist")
        }
        return URL(string: authorizeEndpoint)!
    }
    
    static var oneLoginToken: URL {
        guard let tokenEndpoint = Bundle.main.infoDictionary?["Token Endpoint"] as? String else {
            fatalError("Couldn't fetch Token Endpoint from plist")
        }
        return URL(string: tokenEndpoint)!
    }
}
