import XCTest

struct HomeScreen: ScreenObject {
    let app: XCUIApplication
    
    var view: XCUIElement {
        app.firstMatch
    }
    
    var title: XCUIElement {
        app.navigationBars.staticTexts.firstMatch
    }
}
