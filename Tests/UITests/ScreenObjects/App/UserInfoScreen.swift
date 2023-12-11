import XCTest

struct UserInfoScreen: ScreenObject {
    let app: XCUIApplication

    var view: XCUIElement {
        app.firstMatch
    }

    var title: XCUIElement {
        app.staticTexts["Logged in"]
    }
}
