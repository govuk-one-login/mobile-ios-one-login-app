import DesignSystem
@testable import OneLogin
import Testing
import UIKit

@MainActor
struct SceneDelegateTests {
    @Test
    func test_setUpBasicUI_tabBarTintColor() {
        let sut = SceneDelegate()
        sut.setUpBasicUI()
        #expect(UITabBar.appearance().tintColor == DesignSystem.Color.NavigationElements.selectedTabIconAndLabel)
    }
    
    @Test
    func test_setUpBasicUI_tabBarBackgroundColor() {
        let sut = SceneDelegate()
        sut.setUpBasicUI()
        #expect(UITabBar.appearance().backgroundColor == .systemBackground)
    }
    
    @Test
    func test_setUpBasicUI_barButtonItemTintColor() {
        let sut = SceneDelegate()
        sut.setUpBasicUI()
        let appearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        if #available(iOS 26.0, *) {
            #expect(appearance.tintColor == nil)
        } else {
            #expect(appearance.tintColor == .accent)
        }
    }
}
