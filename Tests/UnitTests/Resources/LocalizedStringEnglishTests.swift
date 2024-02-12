@testable import OneLogin
import XCTest

final class LocalizedStringEnglishTests: XCTestCase {
    override func setUp() {
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
    }
    
    func test_1() {
        XCTAssertEqual(NSLocalizedString("app_continueButton", comment: ""), "Continue")
    }
}
