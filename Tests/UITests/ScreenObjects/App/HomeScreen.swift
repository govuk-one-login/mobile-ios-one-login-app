import XCTest

struct HomeScreen: ScreenObject {
    let app: XCUIApplication
    
    var view: XCUIElement {
        app.firstMatch
    }
    
    var titleImage: XCUIElement {
        app.images.firstMatch
    }
    
    var tabBarsFirstMatch: XCUIElement {
        app.tabBars.firstMatch
    }
}
