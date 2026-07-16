import Authentication
import UIKit

final class MockLoginSession: LoginSession {
    let window: UIWindow
    var sessionConfiguration: LoginSessionConfiguration?
    var didCallPerformLoginFlow = false
    var errorFromPerformLoginFlow: Error?
    var errorFromFinalise: Error?

    init(window: UIWindow) {
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

final class MockLoginSessionNoRefresh: LoginSession {
    let window: UIWindow
    var sessionConfiguration: LoginSessionConfiguration?
    var didCallPerformLoginFlow = false
    var errorFromPerformLoginFlow: Error?
    var errorFromFinalise: Error?

    init(window: UIWindow) {
        self.window = window
    }

    func performLoginFlow(configuration: LoginSessionConfiguration) async throws -> TokenResponse {
        sessionConfiguration = configuration
        didCallPerformLoginFlow = true
        if let errorFromPerformLoginFlow {
            throw errorFromPerformLoginFlow
        } else {
            return try MockTokenResponse().getJSONData(withRefreshToken: false)
        }
    }

    func finalise(redirectURL: URL) throws {
        if let errorFromFinalise {
            throw errorFromFinalise
        }
    }
}

final class MockAppAuthSession: LoginSession {
    
    typealias PerformLoginFlowAsFunction = (LoginSessionConfiguration) async throws -> TokenResponse
    typealias FinaliseAsFunction = (URL) throws -> Void
    
    var performLoginFlowAsFunction: PerformLoginFlowAsFunction
    var finaliseAsFunction: FinaliseAsFunction

    convenience init() {
        self.init(performLoginFlowAsFunction: { configuration in
            return try MockTokenResponse().getJSONData()
        }, finaliseAsFunction: { _ in })
    }
    
    convenience init(performLoginFlowAsFunction: @escaping PerformLoginFlowAsFunction) {
        self.init(performLoginFlowAsFunction: performLoginFlowAsFunction, finaliseAsFunction: { _ in })
    }
    
    init(performLoginFlowAsFunction: @escaping PerformLoginFlowAsFunction, finaliseAsFunction: @escaping FinaliseAsFunction) {
        self.performLoginFlowAsFunction = performLoginFlowAsFunction
        self.finaliseAsFunction = finaliseAsFunction
    }

    func performLoginFlow(configuration: LoginSessionConfiguration) async throws -> TokenResponse {
        return try await self.performLoginFlowAsFunction(configuration)
    }

    func finalise(redirectURL: URL) throws {
        try self.finaliseAsFunction(redirectURL)
    }
}
