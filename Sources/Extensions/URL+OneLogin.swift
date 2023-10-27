import Foundation

extension URL {
    static var oneLoginAuthorize: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = AppEnvironment().string(for: .authorizeEndPoint)
        components.path = "/authorize"
        return components.url!
    }
    
    static var oneLoginToken: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = AppEnvironment().string(for: .tokenEndpoint)
        components.path = "/test"
        return components.url!
    }
}
