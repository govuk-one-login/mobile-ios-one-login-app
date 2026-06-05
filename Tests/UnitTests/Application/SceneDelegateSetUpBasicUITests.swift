@testable import OneLogin
import XCTest

@MainActor
final class SceneDelegateSetUpBasicUITests: XCTestCase {
    var sut: SceneDelegate!

    override func setUp() {
        super.setUp()
        sut = SceneDelegate()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_setUpBasicUI_tabBarTintColor() {
        sut.setUpBasicUI()
        XCTAssertEqual(UITabBar.appearance().tintColor, .tabBar)
    }

    func test_setUpBasicUI_tabBarBackgroundColor() {
        sut.setUpBasicUI()
        XCTAssertEqual(UITabBar.appearance().backgroundColor, .systemBackground)
    }

    func test_setUpBasicUI_barButtonItemTintColor() {
        sut.setUpBasicUI()
        let appearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        XCTAssertEqual(appearance.tintColor, .accent)
    }
}
