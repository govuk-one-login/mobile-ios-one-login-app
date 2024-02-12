@testable import OneLogin
import XCTest

final class LocalizedStringWelshTests: XCTestCase {
    override func setUp() {
        UserDefaults.standard.set(["cy-GB"], forKey: "AppleLanguages")
    }
    
    func test_1() {
        XCTAssertEqual(NSLocalizedString("app_continueButton", comment: ""), "Parhau")
    }
}
