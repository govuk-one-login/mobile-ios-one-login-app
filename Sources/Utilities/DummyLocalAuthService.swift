import LocalAuthenticationWrapper
import UIKit
import Wallet

//
// NOTE: This type is only being used to build the Wallet implementation, this will be replaced with an actual local auth service
//

final class DummyLocalAuthService: LocalAuthService {
    let localAuthentication: LocalAuthManaging

    init(localAuthentication: LocalAuthManaging = LocalAuthenticationWrapper(localAuthStrings: .oneLogin)) {
        self.localAuthentication = localAuthentication
    }
    
    func evaluateLocalAuth(navigationController: UINavigationController,
                           completion: @escaping (AuthType) -> Void) {
        do {
            switch try localAuthentication.type {
            case .faceID:
                completion(.face)
            case .touchID:
                completion(.touch)
            case .passcode:
                completion(.passcode)
            case .none:
                completion(.none)
            }
        } catch {
            fatalError()
        }
    }
}
