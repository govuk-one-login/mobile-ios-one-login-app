import GDSCommon
import LocalAuthentication
import SecureStore

protocol LocalAuthProtocol: RawRepresentable where RawValue == Int {
    static var none: Self { get }
    static var passcodeOnly: Self { get }
    static var touchID: Self { get }
    static var faceID: Self { get }
}

enum LocalAuthenticationType: Int, LocalAuthProtocol {
    case none
    case passcodeOnly
    case touchID
    case faceID
}

protocol LocalAuthenticationManager {
    associatedtype T: LocalAuthProtocol
    var canOnlyUseBiometrics: Bool { get }
    var canUseAnyLocalAuth: Bool { get }
    var type: T { get }
    
    func checkLevelSupported(_ requiredLevel: T) -> Bool
    func enrolFaceIDIfAvailable() async throws -> Bool
}

final class LALocalAuthenticationManager: LocalAuthenticationManager {
    private let context: LocalAuthenticationContext
    
    init(context: LocalAuthenticationContext = LAContext()) {
        self.context = context
    }
    
    var canOnlyUseBiometrics: Bool {
        canUseLocalAuth(type: .deviceOwnerAuthenticationWithBiometrics)
    }
    
    var canUseAnyLocalAuth: Bool {
        canUseLocalAuth(type: .deviceOwnerAuthentication)
    }
    
    var type: some LocalAuthProtocol {
        guard canOnlyUseBiometrics else {
            return canUseAnyLocalAuth ?
            LocalAuthenticationType.passcodeOnly : LocalAuthenticationType.none
        }
        
        switch context.biometryType {
        case .faceID:
            return LocalAuthenticationType.faceID
        case .touchID:
            return LocalAuthenticationType.touchID
        case _ where canUseAnyLocalAuth:
            return LocalAuthenticationType.passcodeOnly
        default:
            return LocalAuthenticationType.none
        }
    }
    
    private func canUseLocalAuth(type policy: LAPolicy) -> Bool {
        return context.canEvaluatePolicy(policy, error: nil)
    }
    
    func checkLevelSupported(_ requiredLevel: some LocalAuthProtocol) -> Bool {
        let supportedLevel = if canOnlyUseBiometrics {
            2
        } else if canUseAnyLocalAuth {
            1
        } else {
            0
        }
        return supportedLevel >= requiredLevel.rawValue
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

protocol LocalAuthenticationContextStringCheck {
    var contextStrings: LocalAuthenticationLocalizedStrings? { get }
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
