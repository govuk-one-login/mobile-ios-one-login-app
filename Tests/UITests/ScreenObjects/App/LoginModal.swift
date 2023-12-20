import XCTest

struct LoginModal: ScreenObject {
    let app: XCUIApplication
    
    var cancelButton: XCUIElement {
        app.buttons["Cancel"]
    }
    
    var view: XCUIElement {
        app.webViews.firstMatch
    }
    
    var title: XCUIElement {
        view.staticTexts["Welcome to the Auth Stub"]
    }
    
    var loginButton: XCUIElement {
        view.buttons["Login"]
    }
    
    var oAuthErrorButton: XCUIElement {
        view.buttons["Redirect with OAuth error"]
    }
    
    var invalidStateButton: XCUIElement {
        view.buttons["Redirect with invalid state"]
    }
    
    var fourHundredResponseErrorButton: XCUIElement {
        view.buttons["Set up 400 response from /token"]
    }
    
    var fiveHundredResponseErrorButton: XCUIElement {
        view.buttons["Set up 500 response from /token"]
    }
    
    func tapCancelButton() {
        cancelButton.tap()
    }
    
    func tapBrowserLoginButton() -> TokensScreen {
        loginButton.tap()
        
        return TokensScreen(app: app).waitForAppearance()
    }
    
    func tapBrowserRedirectWithOAuthErrorButton() -> ErrorScreen {
        oAuthErrorButton.tap()
        
        return ErrorScreen(app: app).waitForAppearance()
    }
    
    func tapBrowserInvalidStateErrorButton() -> ErrorScreen {
        invalidStateButton.tap()
        
        return ErrorScreen(app: app).waitForAppearance()
    }
    
    func tapBrowserFourHundredResponseErrorButton() -> LoginModalSecondScreen {
        fourHundredResponseErrorButton.tap()
        
        let secondModalScreen = LoginModalSecondScreen(app: app).waitForAppearance()
        let browserElements = [
            secondModalScreen.view,
            secondModalScreen.title,
            secondModalScreen.loginButton
        ]
        _ = browserElements.map {
            $0.waitForExistence(timeout: .timeout)
        }
        return secondModalScreen
    }
    
    func tapBrowserFiveHundredResponseErrorButton() -> LoginModalSecondScreen {
        fiveHundredResponseErrorButton.tap()
        
        let secondModalScreen = LoginModalSecondScreen(app: app).waitForAppearance()
        let browserElements = [
            secondModalScreen.view,
            secondModalScreen.title,
            secondModalScreen.loginButton
        ]
        _ = browserElements.map {
            $0.waitForExistence(timeout: .timeout)
        }
        return secondModalScreen
    }
}
