import GDSAnalytics
import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class SignOutConfirmationWalletViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: SignOutConfirmationWalletViewModel!
    
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = SignOutConfirmationWalletViewModel(analyticsService: mockAnalyticsService) {
            self.didCallButtonAction = true
        }
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        didCallButtonAction = false
    }
}

extension SignOutConfirmationWalletViewModelTests {
    func test_pageConfiguration() throws {
        XCTAssertEqual(sut.title.stringKey, "app_signOutConfirmationWalletTitle")
        XCTAssertEqual(sut.body, GDSLocalisedString(stringLiteral: "app_signOutConfirmationWalletBody1").value)
        XCTAssertNil(sut.secondaryButtonViewModel)
        XCTAssertEqual(sut.rightBarButtonTitle, GDSLocalisedString(stringLiteral: "app_cancelButton"))
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_bulletConfiguration() throws {
        XCTAssertNotNil(try bulletList)
        let bulletStack: UIStackView = try XCTUnwrap(bulletList.view?[child: "bullet-stack"])
        let firstBullet = try XCTUnwrap(bulletStack.subviews[0] as? UILabel)
        let firstBulletText = try XCTUnwrap(firstBullet.text)
        XCTAssertTrue(firstBulletText.contains(GDSLocalisedString(stringLiteral: "app_signOutConfirmationWalletBullet1").value))
        let secondBullet = try XCTUnwrap(bulletStack.subviews[1] as? UILabel)
        let secondBulletText = try XCTUnwrap(secondBullet.text)
        XCTAssertTrue(secondBulletText.contains(GDSLocalisedString(stringLiteral: "app_signOutConfirmationWalletBullet2").value))
        let thirdBullet = try XCTUnwrap(bulletStack.subviews[2] as? UILabel)
        let thirdBulletText = try XCTUnwrap(thirdBullet.text)
        XCTAssertTrue(thirdBulletText.contains(GDSLocalisedString(stringLiteral: "app_signOutConfirmationWalletBullet3").value))
    }
    
    func test_viewConfiguration() throws {
        XCTAssertEqual(try body2Label.text, GDSLocalisedString(stringLiteral: "app_signOutConfirmationWalletBody2").value)
        XCTAssertTrue(try body2Label.adjustsFontForContentSizeCategory)
        XCTAssertEqual(try body2Label.numberOfLines, 0)
        XCTAssertEqual(try body2Label.font, .bodyBold)
        XCTAssertEqual(try body3Label.text, GDSLocalisedString(stringLiteral: "app_signOutConfirmationWalletBody3").value)
        XCTAssertTrue(try body3Label.adjustsFontForContentSizeCategory)
        XCTAssertEqual(try body3Label.numberOfLines, 0)
        XCTAssertEqual(try body3Label.font, .body)
    }
    
    func test_buttonConfiuration() throws {
        XCTAssertTrue(sut.buttonViewModel is AnalyticsButtonViewModel)
        XCTAssertEqual(sut.buttonViewModel.title, GDSLocalisedString(stringLiteral: "app_signOutAndDeleteAppDataButton"))
        let button = try XCTUnwrap(sut.buttonViewModel as? AnalyticsButtonViewModel)
        XCTAssertEqual(button.backgroundColor, .gdsRed)
    }
    
    func test_didAppear() throws {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: ProfileAnalyticsScreenID.signOutWalletScreen.rawValue,
                                screen: ProfileAnalyticsScreen.signOutWalletScreen,
                                titleKey: "app_signOutConfirmationWalletTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
    
    func test_didDismiss() throws {
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.didDismiss()
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: "back")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
    
    func test_buttonAction() throws {
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.buttonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: "app_signOutAndDeleteAppDataButton")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
}

extension SignOutConfirmationWalletViewModelTests {
    var bulletList: BulletView {
        get throws {
            try XCTUnwrap(sut.childView[child: "sign-out-bullet-list"])
        }
    }
    
    var body2Label: UILabel {
        get throws {
            try XCTUnwrap(sut.childView[child: "sign-out-body2-text"])
        }
    }
    
    var body3Label: UILabel {
        get throws {
            try XCTUnwrap(sut.childView[child: "sign-out-body3-text"])
        }
    }
}
