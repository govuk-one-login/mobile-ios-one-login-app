import XCTest

extension XCUIElement {
    func tapWhenAppeared(timeout: TimeInterval = .timeout) {
        if waitForExistence(timeout: timeout) {
            tap()
        }
    }
}
