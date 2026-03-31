import XCTest

struct WelcomeScreen: ScreenObject {
    
    static func make() throws -> WelcomeScreen {
        let app = XCUIApplication()
        let welcomeScreen = WelcomeScreen(app: app)
        guard let debugToken = ProcessInfo.processInfo.environment["FIRAAppCheckDebugToken"] else {
            preconditionFailure("No Firebase App Check Debug Token passed in environment")
        }
        app.launchEnvironment["FIRAAppCheckDebugToken"] = debugToken
        app.launch()
        
        guard app.wait(for: .runningForeground, timeout: 10) else {
            XCTFail("Failed to launch the app and have it running in the foreground")
            return welcomeScreen
        }
        
        return welcomeScreen
    }
    
    let app: XCUIApplication
    
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
    
    func waitForUnlockScreenNonExistence() {
        XCTAssertTrue(self.app.staticTexts["unlock-screen-loading-label"].waitForNonExistence(timeout: .timeout),
                      "Loading Screen took longer than \(TimeInterval.timeout) to dismiss")
    }
    
    func agreeIfAnalytics() {
        let analyticsScreen = app.staticTexts["Help improve the app by sharing analytics"]
        
        let analyticsScreenExists = analyticsScreen.waitForExistence(timeout: .timeout)
        
        if analyticsScreenExists {
            let analyticsButton = app.buttons["Share analytics"]
            XCTAssertTrue(analyticsButton.exists)
            // Tap Analytics Permission Button
            analyticsButton.tap()
        }
    }

    
    func tapLoginButton() -> LoginModal {
        signInButton.tap()
        
        let loginModal = LoginModal(app: app)
        let browserElements = [
            loginModal.view,
            loginModal.title,
            loginModal.loginButton,
            loginModal.oAuthErrorButton,
            loginModal.noAuthCodeButton,
            loginModal.fourHundredResponseErrorButton,
            loginModal.fiveHundredResponseErrorButton
        ]
        browserElements.forEach {
            XCTAssertTrue($0.waitForExistence(timeout: .timeout), "\($0) does no exist")
        }
        return loginModal
    }
}
