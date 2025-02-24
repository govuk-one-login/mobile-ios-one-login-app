import Foundation

enum AppRoute {
    case login
    case wallet
    case unknown
}

struct UniversalLinkQualifier {
    static func qualifyOneLoginUniversalLink(_ url: URL) -> AppRoute {
        let path = url.pathComponents
        if path.last == OLString.redirect {
            return .login
        } else if path.contains(where: { $0 == OLString.wallet }) {
            return .wallet
        }
        return .unknown
    }
}
