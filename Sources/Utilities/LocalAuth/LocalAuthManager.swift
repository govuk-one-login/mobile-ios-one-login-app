import GDSCommon
import LocalAuthentication

protocol LocalAuthManagement {
    var biometryType: LABiometryType { get }
    func canUseLocalAuth(type policy: LAPolicy) -> Bool
    @discardableResult func enrolLocalAuth(reason: String) async throws -> Bool
}

final class LocalAuthManager: LocalAuthManagement {
    private var localAuthContext: LocalAuthFacility
    
    init(localAuthContext: LocalAuthFacility = LAContext()) {
        self.localAuthContext = localAuthContext
    }
    
    var biometryType: LABiometryType {
        localAuthContext.biometryType
    }
    
    func canUseLocalAuth(type policy: LAPolicy) -> Bool {
        localAuthContext.canEvaluatePolicy(policy, error: nil)
    }
    
    @discardableResult func enrolLocalAuth(reason: String) async throws -> Bool {
        localAuthContext.localizeAuthPromptStrings()
        return try await localAuthContext
            .evaluatePolicy(.deviceOwnerAuthentication,
                            localizedReason: GDSLocalisedString(stringLiteral: reason).value)
    }
}
