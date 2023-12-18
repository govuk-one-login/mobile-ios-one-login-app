import XCTest

struct LoginModalSecondScreen: ScreenObject {
    let app: XCUIApplication
    
    var view: XCUIElement {
        app.webViews.firstMatch
    }
    
    var title: XCUIElement {
        view.staticTexts["Welcome to the Auth Stub"]
    }
    
    var loginButton: XCUIElement {
        view.buttons["Login"]
    }
    
    func tapBrowserLoginButton() -> ErrorScreen {
        loginButton.tap()
        let errorScreen = ErrorScreen(app: app).waitForAppearance()
        _ = errorScreen.view.waitForExistence(timeout: .timeout)
        return errorScreen
    }
}
