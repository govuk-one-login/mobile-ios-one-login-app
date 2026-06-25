@testable import DesignSystem
@testable import OneLogin
import Testing

@MainActor
struct DataDeletedWarningViewModelTests {
    var sut: DataDeletedWarningViewModel!
    
    init() {
        sut = DataDeletedWarningViewModel {}
    }
}

extension DataDeletedWarningViewModelTests {
    func test_page() throws {
        let errorView = sut.body.first as? GDSErrorIconTitleViewModel
        let bodyText = sut.body[1] as? GDSTextViewModel
        
        #expect(errorView?.icon == .error)
        #expect(errorView?.errorTitle.title.stringKey == "app_dataDeletionWarningTitle")
        #expect(errorView?.errorTitle.title.value == "Something went wrong")
        #expect(errorView?.errorTitle.titleFont == .largeTitleBold)
        #expect(errorView?.errorTitle.alignment == .center)
        
        #expect(bodyText?.title.stringKey == "app_dataDeletionWarningBody")
        // swiftlint:disable:next line_length
        #expect(bodyText?.title.value == "We could not confirm your sign in details.\n\nTo keep your information secure, any documents in your app have been removed and your preferences have been reset.\n\nYou need to sign in and reset your preferences to continue using the app. You’ll then be able to add your documents again.")
        #expect(bodyText?.alignment == .center)
        #expect(sut.movableFooter.count == 1)
        #expect(sut.footer.count == 0)
        #expect(sut.rightBarButtonTitle == nil)
        #expect(sut.backButtonTitle == nil)
        #expect(sut.backButtonIsHidden)
        #expect(sut.didDismiss == nil)
        #expect(sut.didAppear == nil)
    }
    
    func test_button() {
        var didCallPrimaryButtonAction = false
        
        let sut =  DataDeletedWarningViewModel {
            didCallPrimaryButtonAction = true
        }

        let primaryButton = sut.movableFooter.first as? GDSButtonViewModel
        
        #expect(!didCallPrimaryButtonAction)
        #expect(primaryButton?.title.forState(.normal) == "Sign in")
        primaryButton?.buttonAction.perform()
        #expect(didCallPrimaryButtonAction)
    }
}
