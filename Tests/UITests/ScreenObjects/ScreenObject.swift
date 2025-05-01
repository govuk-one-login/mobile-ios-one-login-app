import XCTest

protocol ScreenObject {
    var view: XCUIElement { get }
}

extension ScreenObject {
    var isVisible: Bool {
        view.isHittable
    }
    
    func waitForAppearance(timeout: TimeInterval = .timeout) -> Self {
        _ = view.waitForExistence(timeout: timeout)
        return self
    }
}
