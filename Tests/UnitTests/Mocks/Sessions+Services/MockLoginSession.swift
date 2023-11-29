import Authentication
import UIKit

final class MockLoginSession: LoginSession {
    let window: UIWindow
    var didCallPresent = false
    var didCallFinalise = false
    var didCallCancel = false
    var sessionConfiguration: LoginSessionConfiguration?
    var callbackURL: URL?
    
    init(window: UIWindow = UIWindow()) {
        self.window = window
    }
    
    func authenticate(configuration: LoginSessionConfiguration) {
        didCallPresent = true
        sessionConfiguration = configuration
    }
    
    func finalise(redirectURL: URL) throws -> TokenResponse {
        didCallFinalise = true
        callbackURL = redirectURL
        return try MockTokenResponse().getJSONData()
    }
    
    func cancel() {
        didCallCancel = true
    }
}
