import Authentication
import Networking

enum TokenError: Error {
    case bearerNotPresent
    case expired
}

final class TokenHolder: AuthenticationProvider {
    private(set) var accessToken: String?

    var bearerToken: String {
        get throws {
            guard let accessToken else {
                throw TokenError.bearerNotPresent
            }
            return accessToken
        }
    }

    func update(accessToken: String) {
        self.accessToken = accessToken
    }

    func clear() {
        accessToken = nil
    }
}
