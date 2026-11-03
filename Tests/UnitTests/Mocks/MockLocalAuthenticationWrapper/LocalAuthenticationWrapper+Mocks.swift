import LocalAuthentication
@testable import LocalAuthenticationWrapper

extension LocalAuthenticationWrapper {
    static func make(localAuthContext: LocalAuthContext = MockLocalAuthContext.stub(biometryType: .faceID),
                     localAuthPromptStore: LocalAuthPromptRecorder,
                     localAuthStrings: LocalAuthPromptStrings = .stub()) -> LocalAuthenticationWrapper {
        return LocalAuthenticationWrapper(localAuthContext: localAuthContext, localAuthPromptStore: localAuthPromptStore, localAuthStrings: localAuthStrings)
    }
}

extension LocalAuthPromptStrings {
    static func stub() -> LocalAuthPromptStrings {
        LocalAuthPromptStrings(
            subtitle: "test_reason",
            passcodeButton: "test_passcodeButton",
            cancelButton: "test_cancelButton"
        )
    }
}

final class MockLocalAuthContext: LocalAuthContext {
    static func stub(biometryType: LABiometryType) -> MockLocalAuthContext {
        return MockLocalAuthContext(biometryType: biometryType)
    }

    let biometryType: LABiometryType
    var localizedFallbackTitle: String?
    var localizedCancelTitle: String?

    init(biometryType: LABiometryType, localizedFallbackTitle: String? = nil, localizedCancelTitle: String? = nil) {
        self.biometryType = biometryType
        self.localizedFallbackTitle = localizedFallbackTitle
        self.localizedCancelTitle = localizedCancelTitle
    }

    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        return true
    }

    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool {
        return true
    }
}
