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
        return HomeScreen(app: app).waitForAppearance()
    }
}
