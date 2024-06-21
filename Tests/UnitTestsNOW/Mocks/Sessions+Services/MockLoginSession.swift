import Authentication
import UIKit

final class MockLoginSession: LoginSession {
    let window: UIWindow
    var sessionConfiguration: LoginSessionConfiguration?
    var didCallPerformLoginFlow = false
    var errorFromPerformLoginFlow: Error?
    var errorFromFinalise: Error?

    init(window: UIWindow = UIWindow()) {
        self.window = window
    }

    func performLoginFlow(configuration: LoginSessionConfiguration) async throws -> TokenResponse {
        sessionConfiguration = configuration
        didCallPerformLoginFlow = true
        if let errorFromPerformLoginFlow {
            throw errorFromPerformLoginFlow
        } else {
            return try MockTokenResponse().getJSONData()
        }
    }

    func finalise(redirectURL: URL) throws {
        if let errorFromFinalise {
            throw errorFromFinalise
        }
    }
}
