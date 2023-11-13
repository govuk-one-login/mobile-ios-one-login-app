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

    func tapCancelButton() {
        cancelButton.tap()
    }
}
