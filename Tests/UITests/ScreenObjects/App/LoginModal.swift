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
    
    var noAuthCodeButton: XCUIElement {
        view.buttons["Redirect with no auth code returned"]
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
    
    func tapBrowserLoginButton() -> LoadingScreen {
        loginButton.tap()
        
        return LoadingScreen(app: app)
    }
    
    func tapBrowserRedirectWithOAuthErrorButton() -> ErrorScreen {
        oAuthErrorButton.tap()
        
        let errorScreen = ErrorScreen(app: app)
        
        XCTAssertTrue(errorScreen.title.waitForExistence(timeout: .timeout), "Failed to get matching snapshot: "
                      + "No matches found for Elements matching predicate '\(errorScreen.title) IN identifiers' from input \(app.staticTexts)")
        
        return errorScreen
    }
    
    func tapBrowserNoAuthCodeErrorButton() -> ErrorScreen {
        noAuthCodeButton.tap()
        
        let errorScreen = ErrorScreen(app: app)
        
        XCTAssertTrue(errorScreen.title.waitForExistence(timeout: .timeout), "Failed to get matching snapshot: "
                      + "No matches found for Elements matching predicate '\(errorScreen.title) IN identifiers' from input \(app.staticTexts)")
        
        return errorScreen
    }
    
    func tapBrowserFourHundredResponseErrorButton() -> LoginModalSecondScreen {
        fourHundredResponseErrorButton.tap()
        
        let secondModalScreen = LoginModalSecondScreen(app: app)
        let browserElements = [
            secondModalScreen.view,
            secondModalScreen.title,
            secondModalScreen.loginButton
        ]
        browserElements.forEach {
            XCTAssertTrue($0.waitForExistence(timeout: .timeout), "Failed to get matching snapshot: "
                          + "No matches found for Elements matching predicate '\($0.title) IN identifiers'")
        }
        return secondModalScreen
    }
    
    func tapBrowserFiveHundredResponseErrorButton() -> LoginModalSecondScreen {
        fiveHundredResponseErrorButton.tap()
        
        let secondModalScreen = LoginModalSecondScreen(app: app)
        let browserElements = [
            secondModalScreen.view,
            secondModalScreen.title,
            secondModalScreen.loginButton
        ]
        browserElements.forEach {
            XCTAssertTrue($0.waitForExistence(timeout: .timeout), "Failed to get matching snapshot: "
                          + "No matches found for Elements matching predicate '\($0.title) IN identifiers'")
        }
        return secondModalScreen
    }
}
