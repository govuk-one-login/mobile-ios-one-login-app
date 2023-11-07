import XCTest

struct WelcomeScreenObject: ScreenObject {
    let app = XCUIApplication()
    
    var view: XCUIElement {
        app.scrollViews.firstMatch
    }
    
    var title: XCUIElement {
        app.staticTexts["intro-title"]
    }
    
    var body: XCUIElement {
        app.staticTexts["intro-body"]
    }
    
    var signInButton: XCUIElement {
        app.buttons["intro-button"]
    }
}
