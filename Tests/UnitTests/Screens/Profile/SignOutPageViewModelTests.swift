//
//  SignOutPageViewModelTests.swift
//  OneLogin
//
//  Created by Mihaila, Bianca on 25/09/2024.
//


import GDSAnalytics
import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class SignOutPageViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: SignOutPageViewModel!
    
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = SignOutPageViewModel(analyticsService: mockAnalyticsService) {
            self.didCallButtonAction = true
        }
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        didCallButtonAction = false
    }
}

extension SignOutPageViewModelTests {
    func test_pageConfiguration() throws {
        XCTAssertEqual(sut.title.stringKey, "app_signOutConfirmationTitleNoWallet")
        XCTAssertEqual(sut.body, GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody1NoWallet").value)
        XCTAssertNil(sut.secondaryButtonViewModel)
        XCTAssertEqual(sut.rightBarButtonTitle, GDSLocalisedString(stringLiteral: "app_cancelButton"))
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_bulletConfiguration() throws {
        XCTAssertNotNil(try bulletList)
        let bulletStack: UIStackView = try XCTUnwrap(bulletList.view?[child: "bullet-stack"])
        let firstBullet = try XCTUnwrap(bulletStack.subviews[0] as? UILabel)
        let firstBulletText = try XCTUnwrap(firstBullet.text)
        XCTAssertTrue(firstBulletText.contains(GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet1iOSNoWallet").value))
        let secondBullet = try XCTUnwrap(bulletStack.subviews[1] as? UILabel)
        let secondBulletText = try XCTUnwrap(secondBullet.text)
        XCTAssertTrue(secondBulletText.contains(GDSLocalisedString(stringLiteral: "app_signOutConfirmationBullet2NoWallet").value))
    }
    
    func test_viewConfiguration() throws {
        XCTAssertEqual(try body2Label.text, GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody2NoWallet").value)
        XCTAssertTrue(try body2Label.adjustsFontForContentSizeCategory)
        XCTAssertEqual(try body2Label.numberOfLines, 0)
        XCTAssertEqual(try body2Label.font, .bodyBold)
    }
    
    func test_buttonConfiuration() throws {
        XCTAssertTrue(sut.buttonViewModel is AnalyticsButtonViewModel)
        XCTAssertEqual(sut.buttonViewModel.title, GDSLocalisedString(stringLiteral: "app_signOutAndDeletePreferences"))
        let button = try XCTUnwrap(sut.buttonViewModel as? AnalyticsButtonViewModel)
        XCTAssertEqual(button.backgroundColor, .gdsGreen)
    }
    
    func test_didAppear() throws {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: ProfileAnalyticsScreenID.signOutScreenNoWallet.rawValue,
                                screen: ProfileAnalyticsScreen.signOutScreenNoWallet,
                                titleKey: "app_signOutConfirmationTitleNoWallet")
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
        let event = ButtonEvent(textKey: "app_signOutAndDeletePreferences")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
}

extension SignOutPageViewModelTests {
    var bulletList: BulletView {
        get throws {
            try XCTUnwrap(sut.childView[child: "sign-out-bullet-list-no-wallet"])
        }
    }
    
    var body2Label: UILabel {
        get throws {
            try XCTUnwrap(sut.childView[child: "sign-out-body2-text-no-wallet"])
        }
    }
}
