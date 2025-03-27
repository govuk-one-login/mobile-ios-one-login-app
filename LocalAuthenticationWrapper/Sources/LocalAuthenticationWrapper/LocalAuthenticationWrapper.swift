import LocalAuthentication

final public class LocalAuthenticationWrapper: LocalAuthWrap {
    private let context: LocalAuthenticationContext
    private let localAuthPromptStore: LocalAuthPromptRecorder
    private let localAuthStrings: LocalAuthPromptStrings
    
    public convenience init(
        localAuthStrings: LocalAuthPromptStrings
    ) {
        self.init(
            context: LAContext(),
            localAuthPromptStore: UserDefaults.standard,
            localAuthStrings: localAuthStrings
        )
    }
    
    init(
        context: LocalAuthenticationContext,
        localAuthPromptStore: LocalAuthPromptRecorder,
        localAuthStrings: LocalAuthPromptStrings
    ) {
        self.context = context
        self.localAuthPromptStore = localAuthPromptStore
        self.localAuthStrings = localAuthStrings
    }
    
    public var type: LocalAuthType {
        get throws {
            guard try canOnlyUseBiometrics else {
                return try canUseAnyLocalAuth ? .passcodeOnly : .none
            }
            
            switch context.biometryType {
            case .faceID:
                return .biometry(type: .faceID)
            case .touchID:
                return .biometry(type: .touchID)
            case _ where try canUseAnyLocalAuth:
                return .passcodeOnly
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
        _ requiredLevel: LocalAuthType
    ) throws -> Bool {
        let supportedLevel = if try canOnlyUseBiometrics {
            2
        } else if try canUseAnyLocalAuth {
            1
        } else {
            0
        }
        return supportedLevel >= requiredLevel.rawValue
    }
    
    public func enrolLocalAuth() async throws -> Bool {
        guard try type == .biometry(type: .faceID) &&
                !localAuthPromptStore.previouslyPrompted else {
            // enrolment is not required unless biometry type is FaceID
            // and user has not been previously prompted for permissions
            return true
        }
        do {
            localizeAuthPromptStrings()
            let localAuthResult = try await context
                .evaluatePolicy(
                    .deviceOwnerAuthentication,
                    localizedReason: localAuthStrings.subtitle
                )
            localAuthPromptStore.recordPrompt()
            return localAuthResult
        } catch LAError.appCancel,
                LAError.userCancel,
                LAError.systemCancel {
            throw LocalAuthenticationWrapperError.cancelled
        } catch {
            throw LocalAuthenticationWrapperError
                .generic(description: error.localizedDescription)
        }
    }
    
    private func canUseLocalAuth(
        type policy: LAPolicy
    ) throws -> Bool {
        var error: NSError?
        let localAuthOutcome = context
            .canEvaluatePolicy(
                policy,
                error: &error
            )
        if let error {
            switch error.code {
            case LAError.Code.biometryLockout.rawValue,
                LAError.Code.biometryNotEnrolled.rawValue,
                LAError.Code.biometryNotAvailable.rawValue:
                throw LocalAuthenticationWrapperError.biometricsUnavailable
            default:
                throw LocalAuthenticationWrapperError
                    .generic(description: error.localizedDescription)
            }
        }
        return localAuthOutcome
    }
    
    private func localizeAuthPromptStrings() {
        context.localizedFallbackTitle = localAuthStrings.passcodeButton
        context.localizedCancelTitle = localAuthStrings.cancelButton
    }
}
