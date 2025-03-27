@testable import LocalAuthenticationWrapper
import LocalAuthentication

final class MockLocalAuthContext: LocalAuthContext {
    let biometryType: LABiometryType
    var localizedFallbackTitle: String?
    var localizedCancelTitle: String?
    
    init(biometryType: LABiometryType, localizedFallbackTitle: String? = nil, localizedCancelTitle: String? = nil) {
        self.biometryType = biometryType
        self.localizedFallbackTitle = localizedFallbackTitle
        self.localizedCancelTitle = localizedCancelTitle
    }
    
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        <#code#>
    }
    
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool {
        <#code#>
    }
}
