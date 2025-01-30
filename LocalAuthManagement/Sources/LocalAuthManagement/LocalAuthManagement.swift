import GDSCommon
import LocalAuthentication

public protocol LocalAuthPromptRecorder {
    var previouslyPrompted: Bool { get }
    func recordPrompt()
}

public protocol AppSessionManager {
    func saveLoginSesion()
}

final class LALocalAuthenticationManager: LocalAuthenticationManager {
    private let context: LocalAuthenticationContext
    private let localAuthPromptStore: LocalAuthPromptRecorder
    private let localAuthStrings: LocalAuthPromptStrings
    private let appSessionManager: AppSessionManager
    
    public convenience init(
        localAuthStrings: LocalAuthPromptStrings,
        localAuthPromptStore: LocalAuthPromptRecorder,
        appSessionManager: AppSessionManager
    ) {
        self.init(
            context: LAContext(),
            localAuthPromptStore: localAuthPromptStore,
            localAuthStrings: localAuthStrings,
            appSessionManager: appSessionManager
        )
    }
    
    init(
        context: LocalAuthenticationContext,
        localAuthPromptStore: LocalAuthPromptRecorder,
        localAuthStrings: LocalAuthPromptStrings,
        appSessionManager: AppSessionManager
    ) {
        self.context = context
        self.localAuthPromptStore = localAuthPromptStore
        self.localAuthStrings = localAuthStrings
        self.appSessionManager = appSessionManager
    }
    
    public var type: some LocalAuthType {
        guard canOnlyUseBiometrics else {
            return canUseAnyLocalAuth ? MyLocalAuthType.passcodeOnly : MyLocalAuthType.none
        }
        
        switch context.biometryType {
        case .faceID:
            return MyLocalAuthType.faceID
        case .touchID:
            return MyLocalAuthType.touchID
        case _ where canUseAnyLocalAuth:
            return MyLocalAuthType.passcodeOnly
        default:
            return MyLocalAuthType.none
        }
    }
    
    private var canOnlyUseBiometrics: Bool {
        canUseLocalAuth(
            type: .deviceOwnerAuthenticationWithBiometrics
        )
    }
    
    private var canUseAnyLocalAuth: Bool {
        canUseLocalAuth(
            type: .deviceOwnerAuthentication
        )
    }
    
    public func checkLevelSupported(
        _ requiredLevel: any LocalAuthType
    ) -> Bool {
        let supportedLevel = if canOnlyUseBiometrics {
            type == .touchID ? 3 : 4
        } else if canUseAnyLocalAuth {
            1
        } else {
            0
        }
        return supportedLevel >= requiredLevel.rawValue
    }
    
    public func saveLoginSesion() {
        appSessionManager.saveLoginSesion()
    }
    
    public func enrolFaceIDIfAvailable() async throws -> Bool {
        guard type == .faceID else {
            // enrolment is not required unless biometric type is FaceID
            return true
        }
        do {
            localizeAuthPromptStrings()
            let localAuthResult = try await context
                .evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: localAuthStrings.subtitle
                )
            localAuthPromptStore.recordPrompt()
            localAuthResult ? saveLoginSesion() : nil
            return localAuthResult
        } catch {
            throw error
        }
    }
    
    private func canUseLocalAuth(
        type policy: LAPolicy
    ) -> Bool {
        return context
            .canEvaluatePolicy(
                policy,
                error: nil
            )
    }
    
    private func localizeAuthPromptStrings() {
        context.localizedFallbackTitle = localAuthStrings.passcodeButton
        context.localizedCancelTitle = localAuthStrings.cancelButton
    }
}
