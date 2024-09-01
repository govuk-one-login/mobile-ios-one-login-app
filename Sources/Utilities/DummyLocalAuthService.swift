import LocalAuthentication
import UIKit
import Wallet

//
// NOTE: This type is only being used to build the Wallet implementation, this will be replaced with an actual local auth service
//

final class DummyLocalAuthService: LocalAuthService {
    let context: LocalAuthenticationContext

    init(context: LocalAuthenticationContext) {
        self.context = context
    }
    
    convenience init() {
        self.init(context: LAContext())
    }
    
    func evaluateLocalAuth(navigationController: UINavigationController,
                           completion: @escaping (AuthType) -> Void) {
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: nil) && context.biometryType == .touchID {
            completion(.touch)
        } else if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: nil) && context.biometryType == .faceID {
            completion(.face)
        } else if !context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: nil) {
            completion(.none)
        } else {
            completion(.passcode)
        }
    }
}
