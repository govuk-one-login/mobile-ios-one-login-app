import LocalAuthenticationWrapper
import UIKit
import Wallet

//
// NOTE: This type is only being used to build the Wallet implementation, this will be replaced with an actual local auth service
//

final class DummyLocalAuthService: LocalAuthService {
    let context: LocalAuthWrap

    init() {
        self.context = LocalAuthenticationWrapper(localAuthStrings: .oneLogin)
    }
    
    func evaluateLocalAuth(navigationController: UINavigationController,
                           completion: @escaping (AuthType) -> Void) {
        do {
            switch try context.type {
            case .none:
                completion(.none)
            case .passcode:
                completion(.passcode)
            case .touchID:
                completion(.touch)
            case .faceID:
                completion(.face)
            }
        } catch {
            fatalError()
        }
    }
}
