import XCTest

struct HomeScreen: ScreenObject {
    let app: XCUIApplication
    
    var view: XCUIElement {
        app.tabBars.firstMatch
    }
    
    var titleImage: XCUIElement {
        app.images.firstMatch
    }
}
