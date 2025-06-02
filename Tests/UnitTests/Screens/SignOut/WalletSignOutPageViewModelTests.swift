import GDSAnalytics
import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class WalletSignOutPageViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: WalletSignOutPageViewModel!
    
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = WalletSignOutPageViewModel(analyticsService: mockAnalyticsService) {
            self.didCallButtonAction = true
        }
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        
        didCallButtonAction = false
        
        super.tearDown()
    }
}

extension WalletSignOutPageViewModelTests {
    func test_page() {
        XCTAssertEqual(sut.title.stringKey, "app_signOutConfirmationTitle")
        XCTAssertEqual(sut.body, GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody1").value)
        XCTAssertNil(sut.secondaryButtonViewModel)
        XCTAssertEqual(sut.rightBarButtonTitle, GDSLocalisedString(stringLiteral: "app_cancelButton"))
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_bullets() throws {
        XCTAssertNotNil(try bulletList)
        let bulletStack: UIStackView = try XCTUnwrap(bulletList.view?[child: "bullet-stack"])
        let firstBullet = try XCTUnwrap(bulletStack.subviews[0] as? UILabel)
        let firstBulletText = try XCTUnwrap(firstBullet.text)
        XCTAssertTrue(firstBulletText.contains(GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet1").value))
        let secondBullet = try XCTUnwrap(bulletStack.subviews[1] as? UILabel)
        let secondBulletText = try XCTUnwrap(secondBullet.text)
        XCTAssertTrue(secondBulletText.contains(GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet2").value))
        let thirdBullet = try XCTUnwrap(bulletStack.subviews[2] as? UILabel)
        let thirdBulletText = try XCTUnwrap(thirdBullet.text)
        XCTAssertTrue(thirdBulletText.contains(GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet3").value))
    }
    
    func test_views() throws {
        XCTAssertEqual(try body2Label.text, GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody2").value)
        XCTAssertTrue(try body2Label.adjustsFontForContentSizeCategory)
        XCTAssertEqual(try body2Label.numberOfLines, 0)
        XCTAssertEqual(try body2Label.font, .body)
        XCTAssertEqual(try body3Label.text, GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody3").value)
        XCTAssertTrue(try body3Label.adjustsFontForContentSizeCategory)
        XCTAssertEqual(try body3Label.numberOfLines, 0)
        XCTAssertEqual(try body3Label.font, .body)
    }
    
    func test_button() throws {
        XCTAssertEqual(sut.buttonViewModel.title.stringKey, "app_signOutAndDeleteAppDataButton")
        let button = try XCTUnwrap(sut.buttonViewModel as? AnalyticsButtonViewModel)
        XCTAssertEqual(button.backgroundColor, .gdsRed)
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.buttonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: "app_signOutAndDeleteAppDataButton")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
    
    func test_didAppear() {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: SettingsAnalyticsScreenID.signOutScreenWithWallet.rawValue,
                                screen: SettingsAnalyticsScreen.signOutScreenWithWallet,
                                titleKey: "app_signOutConfirmationTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
    
    func test_didDismiss() {
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.didDismiss()
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: "back")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
}

extension WalletSignOutPageViewModelTests {
    var bulletList: BulletView {
        get throws {
            try XCTUnwrap(sut.childView[child: "sign-out-bullet-list-with-wallet"])
        }
    }
    
    var body2Label: UILabel {
        get throws {
            try XCTUnwrap(sut.childView[child: "sign-out-body2-text-with-wallet"])
        }
    }
    
    var body3Label: UILabel {
        get throws {
            try XCTUnwrap(sut.childView[child: "sign-out-body3-text-with-wallet"])
        }
    }
}
