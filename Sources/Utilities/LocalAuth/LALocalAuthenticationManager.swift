import GDSCommon
import LocalAuthentication
import SecureStore

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

protocol LocalAuthenticationContextStringCheck {
    var contextStrings: LocalAuthenticationLocalizedStrings? { get }
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
            .evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: GDSLocalisedString(
                    stringLiteral: "app_faceId_subtitle"
                ).value
            )
    }

    private func localizeAuthPromptStrings() {
        context.localizedFallbackTitle = GDSLocalisedString(
            stringLiteral: "app_enterPasscodeButton"
        ).value
        context.localizedCancelTitle = GDSLocalisedString(
            stringLiteral: "app_cancelButton"
        ).value
    }
}

extension LALocalAuthenticationManager: LocalAuthenticationContextStringCheck {
    var contextStrings: LocalAuthenticationLocalizedStrings? {
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ?
            LocalAuthenticationLocalizedStrings(
                localizedReason: GDSLocalisedString(
                    stringLiteral: "app_\(context.biometryType == .touchID ? "touch" : "face")Id_subtitle"
                ).value,
                localisedFallbackTitle: GDSLocalisedString(
                    stringLiteral: "app_enterPasscodeButton"
                ).value,
                localisedCancelTitle: GDSLocalisedString(
                    stringLiteral: "app_cancelButton"
                ).value
            )
        : nil
    }
}
