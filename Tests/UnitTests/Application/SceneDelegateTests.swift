import DesignSystem
@testable import OneLogin
import XCTest

@MainActor
final class SceneDelegateTests: XCTestCase {
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
        XCTAssertEqual(UITabBar.appearance().tintColor,
                       DesignSystem.Color.NavigationElements.selectedTabIconAndLabel)
    }
    
    func test_setUpBasicUI_tabBarUnselectedTintColor() {
        sut.setUpBasicUI()
        XCTAssertEqual(UITabBar.appearance().tintColor,
                       UIColor(light: DesignSystem.Color.Buttons.primaryForegroundDisabled,
                               dark: DesignSystem.Color.Buttons.primaryBackgroundDisabled)
        )
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
