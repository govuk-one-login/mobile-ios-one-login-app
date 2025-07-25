import LocalAuthentication

public struct LocalAuthenticationWrapper: LocalAuthManaging {
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
            return deviceBiometricsType
        }
    }
    
    public var deviceBiometricsType: LocalAuthType {
        switch localAuthContext.biometryType {
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        default:
            return .none
        }
    }
    
    public var canUseAnyLocalAuth: Bool {
        get throws {
            var error: NSError?
            let localAuthOutcome = localAuthContext
                .canEvaluatePolicy(
                    .deviceOwnerAuthentication,
                    error: &error
                )
            if let error {
                switch error.code {
                case LAError.passcodeNotSet.rawValue:
                    return false
                default:
                    throw error
                }
            }
            return localAuthOutcome
        }
    }
    
    private var canOnlyUseBiometrics: Bool {
        get throws {
            var error: NSError?
            let localAuthOutcome = localAuthContext
                .canEvaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    error: &error
                )
            if let error {
                switch error.code {
                case LAError.biometryLockout.rawValue,
                    LAError.biometryNotEnrolled.rawValue,
                    LAError.biometryNotAvailable.rawValue:
                    return false
                default:
                    throw error
                }
            }
            return localAuthOutcome
        }
    }
    
    public func checkLevelSupported(
        _ requiredLevel: RequiredLocalAuthLevel
    ) throws -> Bool {
        let supportedLevel = if try canOnlyUseBiometrics {
            LocalAuthTier.anyBiometricsAndPasscode.rawValue
        } else if try canUseAnyLocalAuth {
            LocalAuthTier.passcodeOnly.rawValue
        } else {
            LocalAuthTier.none.rawValue
        }
        return supportedLevel >= requiredLevel.tier
    }
    
    public func hasBeenPrompted() -> Bool {
        return localAuthPromptStore.previouslyPrompted
    }
    
    public func promptForPermission() async throws -> Bool {
        guard try type != .none &&
                !localAuthPromptStore.previouslyPrompted else {
            return true
        }
        // Enrolment is required if biometry type is FaceID
        // and the user has not been previously prompted for permissions
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
    
    private func localizeAuthPromptStrings() {
        localAuthContext.localizedFallbackTitle = localAuthStrings.passcodeButton
        localAuthContext.localizedCancelTitle = localAuthStrings.cancelButton
    }
}
