@testable import DesignSystem
import GDSAnalytics
@testable import OneLogin
import Testing

@MainActor
struct SignOutSuccessfulViewModelTests {
    var sut: SignOutSuccessfulViewModel!
    
    init() {
        sut = SignOutSuccessfulViewModel {}
    }
}

extension SignOutSuccessfulViewModelTests {
    @Test
    func test_page() {
        let titleText = sut.body.first as? GDSTextViewModel
        let bodyText = sut.body[1] as? GDSTextViewModel
        #expect(titleText?.title.stringKey == "app_signedOutTitle")
        #expect(titleText?.alignment == .center)
        #expect(bodyText?.title.stringKey == "app_signedOutBody")
        #expect(bodyText?.alignment == .center)
        #expect(sut.movableFooter.count == 1)
        #expect(sut.footer.count == 0)
        #expect(sut.rightBarButtonTitle == nil)
        #expect(sut.backButtonTitle == nil)
        #expect(sut.backButtonIsHidden)
        #expect(sut.didDismiss == nil)
        #expect(sut.didAppear == nil)
    }
    
    @Test
    func test_button() throws {
        var didCallPrimaryButtonAction = false
        
        let sut = SignOutSuccessfulViewModel {
            didCallPrimaryButtonAction = true
        }

        let primaryButton = sut.movableFooter.first as? GDSButtonViewModel
        
        #expect(!didCallPrimaryButtonAction)
        #expect(primaryButton?.title.forState(.normal) == "Continue")
        primaryButton?.buttonAction.perform()
        #expect(didCallPrimaryButtonAction)
    }
}
