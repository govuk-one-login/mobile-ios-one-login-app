import XCTest

struct ErrorScreen: ScreenObject {
    let app: XCUIApplication
    
    var view: XCUIElement {
        app.scrollViews.firstMatch
    }
    
    var title: XCUIElement {
        app.staticTexts["error-screen-title"]
    }
    
    var closeButton: XCUIElement {
        app.buttons["error-screen-button-0"]
    }
    
    func tapCloseButton() {
        closeButton.tap()
    }
}
