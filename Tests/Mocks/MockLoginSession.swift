import Authentication
@testable import OneLogin
import UIKit

final class MockLoginSession: LoginSession {
    let window: UIWindow
    var didCallPresent = false
    var didCallFinalise = false
    var didCallCancel = false
    
    init(window: UIWindow = UIWindow()) {
        self.window = window
    }
    
    func present(configuration: LoginSessionConfiguration) {
        didCallPresent = true
    }
    
    func finalise(callback: URL) async throws -> TokenResponse {
        didCallFinalise = true
        return try await MockTokenResponse().getJSONData()
    }
    
    func cancel() {
        didCallCancel = true
    }
}
