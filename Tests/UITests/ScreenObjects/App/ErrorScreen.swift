import XCTest

struct ErrorScreen: ScreenObject {
    let app: XCUIApplication
    
    var view: XCUIElement {
        title
    }
    
    var title: XCUIElement {
        app.staticTexts["error-title"]
    }
    
    var body: XCUIElement {
        app.staticTexts["error-body"]
    }
    
    var closeButton: XCUIElement {
        app.buttons["error-primary-button"]
    }
    
    func tapCloseButton() {
        closeButton.tap()
    }
}
