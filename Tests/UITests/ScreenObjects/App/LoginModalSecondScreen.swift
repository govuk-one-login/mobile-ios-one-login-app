import XCTest

struct LoginModalSecondScreen: ScreenObject {
    let app: XCUIApplication
    
    var view: XCUIElement {
        title
    }
    
    var title: XCUIElement {
        view.staticTexts["Welcome to the Auth Stub"]
    }
    
    var loginButton: XCUIElement {
        view.buttons["Login"]
    }
    
    func tapBrowserLoginButton() -> ErrorScreen {
        loginButton.tap()
        
        return ErrorScreen(app: app).waitForAppearance()
    }
}
