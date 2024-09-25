@testable import OneLogin

final class MockQualifyingService: QualifyingService {
    var delegate: (any OneLogin.AppQualifyingServiceDelegate)?
    
    func initiate() {

    }
    
    func evaluateUser() async {
        
    }
    

}
