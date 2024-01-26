import XCTest

struct TokensScreen: ScreenObject {
    let app: XCUIApplication
    
    var view: XCUIElement {
        app.firstMatch
    }
    
    var title: XCUIElement {
        app.staticTexts["logged-in-title"]
    }
}
