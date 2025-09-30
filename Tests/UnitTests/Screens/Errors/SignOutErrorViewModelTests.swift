import GDSAnalytics
import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class SignOutErrorViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: SignOutErrorViewModel!
    
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = SignOutErrorViewModel(analyticsService: mockAnalyticsService,
                                    error: MockWalletError.cantDelete) { }
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        didCallButtonAction = false
        
        super.tearDown()
    }
}

extension SignOutErrorViewModelTests {
    func test_pageWithWallet() throws {
        sut = SignOutErrorViewModel(analyticsService: mockAnalyticsService,
                                    error: MockWalletError.cantDelete) { self.didCallButtonAction = true }
        XCTAssertEqual(sut.image, .error)
        XCTAssertEqual(sut.title.stringKey, "app_signOutErrorTitle")
        let contentView = try XCTUnwrap(sut.bodyContent.first as? BodyTextViewModel)
        let contentLabel = try XCTUnwrap(contentView.uiView as? UILabel)
        XCTAssertEqual(contentLabel.text, GDSLocalisedString(stringLiteral: "app_signOutErrorBody").value)
        XCTAssertTrue(sut.error as? MockWalletError == .cantDelete)
        XCTAssertEqual(sut.rightBarButtonTitle?.stringKey, "app_cancelButton")
        XCTAssertTrue(sut.backButtonIsHidden)
        XCTAssertEqual(sut.buttonViewModels[0].title.stringKey, "app_signOutErrorButton")
        let button = try XCTUnwrap(sut.buttonViewModels.first as? AnalyticsButtonViewModel)
        button.action()
        XCTAssertTrue(didCallButtonAction)
    }
    
    func test_didAppear() {
        XCTAssertEqual(mockAnalyticsService.crashesLogged.count, 0)
        XCTAssertEqual(mockAnalyticsService.screenViews.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.crashesLogged.count, 1)
        XCTAssertEqual(mockAnalyticsService.screenViews.count, 1)
        XCTAssertTrue(mockAnalyticsService.crashesLogged.first as? MockWalletError == .cantDelete)
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.signOut.rawValue,
                                     screen: ErrorAnalyticsScreen.signOut,
                                     titleKey: "app_signOutErrorTitle",
                                     reason: MockWalletError.cantDelete.localizedDescription)
        XCTAssertEqual(mockAnalyticsService.screenViews as? [ErrorScreenView], [screen])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
}
