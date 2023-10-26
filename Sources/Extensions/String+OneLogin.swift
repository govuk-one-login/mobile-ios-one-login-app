import Foundation

extension String {
    static var oneLoginRedirect: String {
        return AppEnvironment.string(for: .redirectURL)
    }
}
