import GDSAnalytics
import GDSCommon
@testable import OneLogin
import XCTest


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
    func test_buttonContents() throws {
        XCTAssertEqual(sut.buttonViewModel.title.stringKey, "app_signOutAndDeleteAppDataButton")
    }

    func test_textContents() throws {
        XCTAssertEqual(sut.title.stringKey, "app_signOutConfirmationTitle")
        XCTAssertEqual(sut.body, GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody1").value)
        XCTAssertNil(sut.secondaryButtonViewModel)
        XCTAssertTrue(sut.backButtonIsHidden)
        XCTAssertEqual(try body2Label.text, GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody2").value)
        XCTAssertEqual(try body3Label.text, GDSLocalisedString(stringLiteral: "app_signOutConfirmationBody3").value)
    }

    func test_bulletsAreAdded() throws {
        XCTAssertNotNil(try bulletList)
    }

    func test_didAppear() throws {

    }

    func test_buttonAction() throws {
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.buttonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
    }
}

extension SignOutPageViewModelTests {
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

    var bulletList: BulletView {
        get throws {
            try XCTUnwrap(sut.childView[child: "sign-out-bullet-list"])
        }
    }
}
