import LocalAuthenticationWrapper
import UIKit
import Wallet

//
// NOTE: This type is only being used to build the Wallet implementation, this will be replaced with an actual local auth service
//

final class DummyLocalAuthService: WalletLocalAuthService {
    let localAuthentication: LocalAuthManaging

    init(localAuthentication: LocalAuthManaging = LocalAuthenticationWrapper(localAuthStrings: .oneLogin)) {
        self.localAuthentication = localAuthentication
    }
    
    func ensureLocalAuthEnrolled(_ minumumLevel: any WalletLocalAuthType) -> Bool {
        isEnrolled(minumumLevel)
    }
    
    func enrolLocalAuth(_ minimum: any WalletLocalAuthType, completion: @escaping () -> Void) {
        completion()
    }
    
    func isEnrolled(_ minimum: any WalletLocalAuthType) -> Bool {
        return (try? localAuthentication.checkLevelSupported(.anyBiometricsAndPasscode)) ?? false
    }
}
