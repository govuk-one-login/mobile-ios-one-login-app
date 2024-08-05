import Authentication
import LocalAuthentication
import UIKit

//
// NOTE: This type is only being used to build the Wallet implementation, this will be replaced with an actual local auth service
//

struct DummyLocalAuthService: LocalAuthService {
    let context: LAContexting
    
    func evaluateLocalAuth(navigationController: UINavigationController,
                           completion: @escaping (AuthType) -> Void) {
        if (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: nil) && context.biometryType == .touchID) {
            completion(.touch)
        } else if (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: nil) && context.biometryType == .faceID) {
            completion(.face)
        } else if !context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: nil) {
            completion(.none)
        } else{
            completion(.passcode)
        }
    }
}
