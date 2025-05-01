import XCTest

struct WelcomeScreen: ScreenObject {
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
    
    func tapLoginButton() -> LoginModal {
        signInButton.tap()
        
        let loginModal = LoginModal(app: app).waitForAppearance()
        let browserElements = [
            loginModal.view,
            loginModal.title,
            loginModal.loginButton,
            loginModal.oAuthErrorButton,
            loginModal.noAuthCodeButton,
            loginModal.fourHundredResponseErrorButton,
            loginModal.fiveHundredResponseErrorButton
        ]
        browserElements.map {
            _ = $0.waitForExistence(timeout: .timeout)
        }
        return loginModal
    }
}
