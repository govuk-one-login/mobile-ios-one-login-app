import XCTest

protocol ScreenObject {
    var view: XCUIElement { get }
}

extension ScreenObject {
    var isVisible: Bool {
        view.isHittable
    }
}
