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
            let urlHost = if #available(iOS 16.0, *) { url.host() } else { url.host }
            let appHost = if #available(iOS 16.0, *) { AppEnvironment.mobileRedirect.host() } else { AppEnvironment.mobileRedirect.host }
            if urlHost == appHost {
                return .login(url: url)
            } else {
                guard let incomingURLQueryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
                    return .unknown
                }
                var baseURLComponents = URLComponents(url: AppEnvironment.mobileRedirect, resolvingAgainstBaseURL: false)
                baseURLComponents?.queryItems = incomingURLQueryItems
                guard let finalURL = baseURLComponents?.url else {
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
