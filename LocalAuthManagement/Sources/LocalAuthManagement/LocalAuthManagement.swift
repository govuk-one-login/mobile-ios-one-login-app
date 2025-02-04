import GDSCommon
import LocalAuthentication

public protocol LocalAuthPromptRecorder {
    var previouslyPrompted: Bool { get }
    func recordPrompt()
}

enum LocalAuthManagerError: Error {
    case noLocalAuthToEnrol
}

final class LALocalAuthenticationManager: LocalAuthenticationManager {
    private let context: LocalAuthenticationContext
    private let localAuthStrings: LocalAuthPromptStrings
    private let localAuthPromptStore: LocalAuthPromptRecorder
    
    public convenience init(
        localAuthStrings: LocalAuthPromptStrings,
        localAuthPromptStore: LocalAuthPromptRecorder
    ) {
        self.init(
            context: LAContext(),
            localAuthStrings: localAuthStrings,
            localAuthPromptStore: localAuthPromptStore
        )
    }
    
    init(
        context: LocalAuthenticationContext,
        localAuthStrings: LocalAuthPromptStrings,
        localAuthPromptStore: LocalAuthPromptRecorder
    ) {
        self.context = context
        self.localAuthStrings = localAuthStrings
        self.localAuthPromptStore = localAuthPromptStore
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
    
    public func checkMinimumLevel(
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
    
    public func enrolLocalAuth() async throws -> Bool {
        guard type != .none else {
            throw LocalAuthManagerError.noLocalAuthToEnrol
        }
        guard type == .faceID else {
            // enrolment is not required unless biometric type is FaceID
            // localAuthResult ? post notification : nil
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
//            localAuthResult ? post notification : nil
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
