import XCTest

final class LoginUITests: XCTestCase {
    var sut: WelcomeScreenObject!
    
    override func setUp() async throws {
        continueAfterFailure = false
        
        await MainActor.run {
            sut = WelcomeScreenObject()
            sut.app.launch()
        }
    }
    
    override func tearDown() {
        sut.app.terminate()
        sut = nil
    }
}
