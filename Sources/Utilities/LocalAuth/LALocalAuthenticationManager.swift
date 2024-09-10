import GDSCommon
import LocalAuthentication

enum LocalAuthenticationType {
    case touchID
    case faceID
    case passcodeOnly
    case none
}

protocol LocalAuthenticationManager {
    var type: LocalAuthenticationType { get }

    func canUseLocalAuth(type policy: LAPolicy) -> Bool
    func enrolFaceIDIfAvailable() async throws -> Bool
}

final class LALocalAuthenticationManager: LocalAuthenticationManager {
    private let context: LocalAuthenticationContext

    init(context: LocalAuthenticationContext = LAContext()) {
        self.context = context
    }
    
    var type: LocalAuthenticationType {
        guard canUseLocalAuth(type: .deviceOwnerAuthenticationWithBiometrics) else {
            return canUseLocalAuth(type: .deviceOwnerAuthentication) ?
                .passcodeOnly : .none
        }

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case _ where context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil):
            return .passcodeOnly
        default:
            return .none
        }
    }
    
    func canUseLocalAuth(type policy: LAPolicy) -> Bool {
        context.canEvaluatePolicy(policy, error: nil)
    }
    
    func enrolFaceIDIfAvailable() async throws -> Bool {
        guard type == .faceID else {
            // enrolment is not required unless biometric type is FaceID
            return true
        }
        localizeAuthPromptStrings()
        return try await context
            .evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                            localizedReason: GDSLocalisedString(stringLiteral: "app_faceId_subtitle").value)
    }

    private func localizeAuthPromptStrings() {
        context.localizedFallbackTitle = GDSLocalisedString(stringLiteral: "app_enterPasscodeButton").value
        context.localizedCancelTitle = GDSLocalisedString(stringLiteral: "app_cancelButton").value
    }
}
