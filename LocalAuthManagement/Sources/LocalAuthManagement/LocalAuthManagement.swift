import GDSCommon
import LocalAuthentication

final class LALocalAuthenticationManager<T: LocalAuthType>: LocalAuthenticationManager {
    private let context: LocalAuthenticationContext
    private let localAuthStrings: LocalAuthPromptStrings
    
    init(
        context: LocalAuthenticationContext = LAContext(),
        localAuthStrings: LocalAuthPromptStrings
    ) {
        self.context = context
        self.localAuthStrings = localAuthStrings
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
    
    public var type: T {
        guard canOnlyUseBiometrics else {
            return canUseAnyLocalAuth ? .passcodeOnly : .none
        }
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case _ where canUseAnyLocalAuth:
            return .passcodeOnly
        default:
            return .none
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
    
    public func checkLevelSupported(
        _ requiredLevel: T
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
    
    public func enrolFaceIDIfAvailable() async throws -> Bool {
        guard type == .faceID else {
            // enrolment is not required unless biometric type is FaceID
            return true
        }
        localizeAuthPromptStrings()
        return try await context
            .evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: localAuthStrings.subtitle
            )
    }
    
    private func localizeAuthPromptStrings() {
        context.localizedFallbackTitle = localAuthStrings.passcodeButton
        context.localizedCancelTitle = localAuthStrings.cancelButton
    }
}
