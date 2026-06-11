@testable import DesignSystem
@testable import OneLogin
import Testing

@MainActor
struct AnalyticsPreferenceViewModelTests {
    var sut: AnalyticsPreferenceViewModel!

    init() {
        sut = AnalyticsPreferenceViewModel {}
        secondaryButtonAction: {}
        textButtonAction: {}
    }
}

extension AnalyticsPreferenceViewModelTests {
    @Test
    func test_screen_contents() {
        let titleText = sut.body.first as? GDSTextViewModel
        let bodyText = sut.body[1] as? GDSTextViewModel
        #expect(titleText?.title.stringKey == "app_acceptAnalyticsPreferences_title")
        #expect(bodyText?.title.stringKey == "acceptAnalyticsPreferences_body")
        #expect(bodyText?.title.variableKeys == ["app_nameString", "app_nameString"])
        #expect(bodyText?.textColor == .label)
    }
    
    @Test
    func test_primaryButton() throws {
        var didCallPrimaryButtonAction = false
        
        let sut =  AnalyticsPreferenceViewModel {
            didCallPrimaryButtonAction = true
        }
        secondaryButtonAction: {}
        textButtonAction: {}

        let primaryButton = sut.movableFooter.first as? GDSButtonViewModel
        
        #expect(!didCallPrimaryButtonAction)
        #expect(primaryButton?.title.forState(.normal) == "Share analytics")
        primaryButton?.buttonAction.perform()
        #expect(didCallPrimaryButtonAction)
    }

    @Test
    func test_secondaryButton_action() {
        var didCallSecondaryButtonAction = false
        
        let sut =  AnalyticsPreferenceViewModel {}
        secondaryButtonAction: {
            didCallSecondaryButtonAction = true
        }
        textButtonAction: {}

        let secondaryButton = sut.movableFooter[1] as? GDSButtonViewModel
        
        #expect(!didCallSecondaryButtonAction)
        #expect(secondaryButton?.title.forState(.normal) == "Skip for now")
        secondaryButton?.buttonAction.perform()
        #expect(didCallSecondaryButtonAction)
    }
    
    @Test
    func test_textButton_action() {
        var didCallTextButtonAction = false
        
        let sut = AnalyticsPreferenceViewModel {}
        secondaryButtonAction: {}
        textButtonAction: {
            didCallTextButtonAction = true
        }
        let textButton = sut.body[2] as? GDSButtonViewModel
        
        #expect(!didCallTextButtonAction)
        #expect(textButton?.title.forState(.normal) == "Read more about this in the GOV.UK One Login privacy notice")
        textButton?.buttonAction.perform()
        #expect(didCallTextButtonAction)
        #expect(textButton?.accessibilityHint == "Opens in web browser")
    }
}
