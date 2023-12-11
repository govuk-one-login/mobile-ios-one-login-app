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


    func tapCancelButton() {
        cancelButton.tap()
    }

    func tapRedirectOAuthErrorButton() -> GenericErrorScreen {
        oAuthErrorButton.tap()

        let errorScreen =  GenericErrorScreen(app: app).waitForAppearance()
        _ = errorScreen.view.waitForExistence(timeout: .timeout)
        return errorScreen
    }
}
