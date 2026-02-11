import Foundation

enum AppRoute {
    case login(url: URL)
    case wallet
    case unknown
}

struct UniversalLinkQualifier {
    static func qualifyOneLoginUniversalLink(_ url: URL) -> AppRoute {
        let path = url.pathComponents
        if path.last == OLString.redirect {
            guard let urlHost = url.host(),
                  let appHost = AppEnvironment.mobileRedirect.host() else {
                return .unknown
            }
            
            if urlHost == appHost {
                return .login(url: url)
            } else {
                guard let incomingURL = URLComponents(url: url, resolvingAgainstBaseURL: false),
                      var baseRedirectURL = URLComponents(url: AppEnvironment.mobileRedirect, resolvingAgainstBaseURL: false) else {
                    return .unknown
                }
                
                baseRedirectURL.path = incomingURL.path
                baseRedirectURL.queryItems = incomingURL.queryItems
                
                guard let finalURL = baseRedirectURL.url else {
                    return .unknown
                }
                return .login(url: finalURL)
            }
        } else if path.contains(where: { $0 == OLString.wallet }) {
            return .wallet
        }
        return .unknown
    }
}
