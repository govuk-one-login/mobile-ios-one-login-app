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
        _ = loginModal.view.waitForExistence(timeout: .timeout)
        return loginModal
    }
}
