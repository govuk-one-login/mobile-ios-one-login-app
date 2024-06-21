#if NOW
@testable import OneLoginNOW
#else
@testable import OneLogin
#endif

import XCTest

@MainActor
final class WindowManagerTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var windowScene: UIWindowScene!
    var sut: WindowManager!
    
    override func setUp() {
        mockAnalyticsService = MockAnalyticsService()
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        self.windowScene = windowScene!
        sut = WindowManager(windowScene: self.windowScene)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        windowScene = nil
        sut = nil
    }
}

extension WindowManagerTests {
    func test_displayUnlockWindow() throws {
        sut.displayUnlockWindow(analyticsService: mockAnalyticsService) { }
        XCTAssertNotNil(sut.unlockWindow)
        XCTAssertTrue(sut.unlockWindow?.rootViewController is UnlockScreenViewController)
        XCTAssertEqual(sut.unlockWindow?.windowLevel, .alert)
    }
    
    func test_hideUnlockScreen() throws {
        sut.hideUnlockWindow()
        XCTAssertNil(sut.unlockWindow)
    }
}
