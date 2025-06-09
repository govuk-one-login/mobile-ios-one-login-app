import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class WelcomeTileViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: WelcomeTileViewModel!
        
    override func setUp() {
        super.setUp()
        
        sut = WelcomeTileViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
}

extension WelcomeTileViewModelTests {
    func test_view_contents() {
        XCTAssertEqual(sut.title.stringKey, "app_welcomeTileHeader")
        XCTAssertEqual(sut.title.value, "Welcome")
        XCTAssertEqual(sut.body.stringKey, "app_welcomeTileBody1")
        XCTAssertEqual(sut.body.value, "You can use this app to prove your identity to access some government services.")
        XCTAssertFalse(sut.showSeparatorLine)
        XCTAssertEqual(sut.backgroundColour, .secondarySystemGroupedBackground)
    }
}
