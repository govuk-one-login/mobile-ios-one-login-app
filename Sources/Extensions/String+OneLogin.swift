import Foundation

extension String {
    static var oneLoginRedirect: String {
        guard let redirectURL = Bundle.main.infoDictionary?["Redirect URL"] as? String else {
            fatalError("Couldn't fetch Redirect URL from plist")
        }
        return redirectURL
    }
}
