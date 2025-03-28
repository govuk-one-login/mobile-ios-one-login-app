import LocalAuthentication

public struct LocalAuthenticationWrapper: LocalAuthWrap {
    private let localAuthContext: LocalAuthContext
    private let localAuthPromptStore: LocalAuthPromptRecorder
    private let localAuthStrings: LocalAuthPromptStrings
    
    public init(
        localAuthStrings: LocalAuthPromptStrings
    ) {
        self.init(
            localAuthContext: LAContext(),
            localAuthPromptStore: UserDefaults.standard,
            localAuthStrings: localAuthStrings
        )
    }
    
    init(
        localAuthContext: LocalAuthContext,
        localAuthPromptStore: LocalAuthPromptRecorder,
        localAuthStrings: LocalAuthPromptStrings
    ) {
        self.localAuthContext = localAuthContext
        self.localAuthPromptStore = localAuthPromptStore
        self.localAuthStrings = localAuthStrings
    }
    
    public var type: LocalAuthType {
        get throws {
            guard try canOnlyUseBiometrics else {
                return try canUseAnyLocalAuth ? .passcode : .none
            }
            
            switch localAuthContext.biometryType {
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            default:
                return .none
            }
        }
    }
    
    private var canOnlyUseBiometrics: Bool {
        get throws {
            try canUseLocalAuth(
                type: .deviceOwnerAuthenticationWithBiometrics
            )
        }
    }
    
    private var canUseAnyLocalAuth: Bool {
        get throws {
            try canUseLocalAuth(
                type: .deviceOwnerAuthentication
            )
        }
    }
    
    public func checkMinimumLevel(
        _ requiredLevel: RequiredLocalAuthLevel
    ) throws -> Bool {
        let supportedLevel = if try canOnlyUseBiometrics {
            2
        } else if try canUseAnyLocalAuth {
            1
        } else {
            0
        }
        return supportedLevel >= requiredLevel.tier
    }
    
    public func enrolLocalAuth() async throws -> Bool {
        guard try type == .faceID &&
                !localAuthPromptStore.previouslyPrompted else {
            // enrolment is not required unless biometry type is FaceID
            // and user has not been previously prompted for permissions
            return true
        }
        do {
            localizeAuthPromptStrings()
            let localAuthResult = try await localAuthContext
                .evaluatePolicy(
                    .deviceOwnerAuthentication,
                    localizedReason: localAuthStrings.subtitle
                )
            localAuthPromptStore.recordPrompt()
            return localAuthResult
        } catch let error as NSError {
            switch error.code {
            case LAError.appCancel.rawValue,
                LAError.userCancel.rawValue,
                LAError.systemCancel.rawValue:
                throw LocalAuthenticationWrapperError.cancelled
            default:
                throw error
            }
        }
    }
    
    private func canUseLocalAuth(
        type policy: LAPolicy
    ) throws -> Bool {
        var error: NSError?
        let localAuthOutcome = localAuthContext
            .canEvaluatePolicy(
                policy,
                error: &error
            )
        if let error {
            switch error.code {
            case LAError.biometryLockout.rawValue,
                LAError.biometryNotEnrolled.rawValue,
                LAError.biometryNotAvailable.rawValue:
                throw LocalAuthenticationWrapperError.biometricsUnavailable
            default:
                throw error
            }
        }
        return localAuthOutcome
    }
    
    private func localizeAuthPromptStrings() {
        localAuthContext.localizedFallbackTitle = localAuthStrings.passcodeButton
        localAuthContext.localizedCancelTitle = localAuthStrings.cancelButton
    }
}
