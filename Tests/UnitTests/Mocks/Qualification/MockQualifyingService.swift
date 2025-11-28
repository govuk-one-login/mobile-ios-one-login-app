@testable import OneLogin

final class MockQualifyingService: QualifyingService {
    var delegate: (any OneLogin.AppQualifyingServiceDelegate)?
    var didCallInitiate: Bool = false
    
    func initiate() {
        didCallInitiate = true
    }
    
    func evaluateUserSession() async {
        
    }
    

}
