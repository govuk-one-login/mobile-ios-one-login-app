import XCTest

struct PasscodeInformationScreen: ScreenObject {
    let app: XCUIApplication
    
    var view: XCUIElement {
        app.scrollViews.firstMatch
    }
    
    var title: XCUIElement {
        app.staticTexts["information-title"]
    }
    
    var body: XCUIElement {
        app.staticTexts["information-body"]
    }
    
    var continueButton: XCUIElement {
        app.buttons["information-primary-button"]
    }
    
    func tapContinueButton() -> TokensScreen {
        continueButton.tap()
        
        return TokensScreen(app: app).waitForAppearance()
    }
}
