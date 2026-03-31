import XCTest

struct LoadingScreen: ScreenObject {
    let app: XCUIApplication
    
    var view: XCUIElement {
        app.firstMatch
    }
    
    var title: XCUIElement {
        app.staticTexts["loadingLabel"]
    }
    
    func waitForHomeScreen() -> HomeScreen {
        let homeScreen = HomeScreen(app: app)
        
        XCTAssertTrue(homeScreen.tabBarsFirstMatch.waitForExistence(timeout: .timeout), "\(homeScreen) does no exist")
        
        return homeScreen
    }
}
