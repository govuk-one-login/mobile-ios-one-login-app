import XCTest

struct GenericErrorScreen: ScreenObject {
    let app: XCUIApplication

    var view: XCUIElement {
        app.scrollViews.firstMatch
    }

    var title: XCUIElement {
        app.staticTexts["Something went wrong"]
    }

    var body: XCUIElement {
        app.staticTexts["Try again later"]
    }

    var closeButton: XCUIElement {
        app.buttons["Close"]
    }

    func tapCloseButton() {
        closeButton.tap()
    }
}
