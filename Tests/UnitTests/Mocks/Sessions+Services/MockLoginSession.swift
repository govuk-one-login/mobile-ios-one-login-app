import Authentication
import UIKit

final class MockLoginSession: LoginSession {
    let window: UIWindow
    var didCallPresent = false
    var didCallFinalise = false
    var didCallCancel = false
    var errorFromLoginFlow: Error?
    var sessionConfiguration: LoginSessionConfiguration?
    var callbackURL: URL?

    init(window: UIWindow = UIWindow()) {
        self.window = window
    }

    func performLoginFlow(configuration: LoginSessionConfiguration) async throws -> TokenResponse {
        didCallPresent = true
        sessionConfiguration = configuration
        if let errorFromLoginFlow {
            throw errorFromLoginFlow
        } else {
            return try MockTokenResponse().getJSONData()
        }
    }

    func finalise(redirectURL: URL) throws {
        didCallFinalise = true
        callbackURL = redirectURL
    }

    func cancel() {
        didCallCancel = true
    }
}
