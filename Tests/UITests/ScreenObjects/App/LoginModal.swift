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

    func tapBrowserLoginButton() -> UserInfoScreen {
        loginButton.tap()
        let userInfoScreen = UserInfoScreen(app: app).waitForAppearance()
        return userInfoScreen
    }

    func tapRedirectOAuthErrorButton() -> GenericErrorScreen {
        oAuthErrorButton.tap()

        let errorScreen =  GenericErrorScreen(app: app).waitForAppearance()
        return errorScreen
    }
}
