import Authentication
import Networking

enum TokenError: Error {
    case bearerNotPresent
    case expired
}

final class TokenHolder: AuthenticationProvider {
    var accessToken: String? {
        tokenResponse?.accessToken
    }

    var bearerToken: String {
        get throws {
            guard let accessToken else {
                throw TokenError.bearerNotPresent
            }
            return accessToken
        }
    }

    private var tokenResponse: TokenResponse?

    func update(tokens: TokenResponse) {
        self.tokenResponse = tokens
    }

    func clear() {
        tokenResponse = nil
    }
}
