@testable import OneLogin
import XCTest

@MainActor
final class AnalyticsPreferenceViewModelTests: XCTestCase {
    var sut: AnalyticsPreferenceViewModel!
    
    var didCallPrimaryButtonAction = false
    var didCallSecondaryButtonAction = false
    var didCallTextButtonAction = false

    override func setUp() {
        super.setUp()

        sut = AnalyticsPreferenceViewModel {
            self.didCallPrimaryButtonAction = true
        } secondaryButtonAction: {
            self.didCallSecondaryButtonAction = true
        } textButtonAction: {
            self.didCallTextButtonAction = true
        }
    }

    override func tearDown() {
        sut = nil
        
        didCallPrimaryButtonAction = false
        didCallSecondaryButtonAction = false
        didCallTextButtonAction = false
        
        super.tearDown()
    }
}

extension AnalyticsPreferenceViewModelTests {
    func test_screen_contents() throws {
        XCTAssertEqual(sut.title.stringKey, "app_acceptAnalyticsPreferences_title")
        XCTAssertEqual(sut.body.stringKey, "acceptAnalyticsPreferences_body")
        XCTAssertEqual(sut.bodyTextColor, .label)
    }

    func test_primaryButton() throws {
        XCTAssertEqual(sut.primaryButtonViewModel.title.stringKey, "app_shareAnalyticsButton")
        XCTAssertFalse(didCallPrimaryButtonAction)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallPrimaryButtonAction)
        XCTAssertNil(sut.primaryButtonViewModel.accessibilityHint)
    }

    func test_secondaryButton_action() throws {
        XCTAssertEqual(sut.secondaryButtonViewModel.title.stringKey, "app_doNotShareAnalytics")
        XCTAssertFalse(didCallSecondaryButtonAction)
        sut.secondaryButtonViewModel.action()
        XCTAssertTrue(didCallSecondaryButtonAction)
        XCTAssertNil(sut.secondaryButtonViewModel.accessibilityHint)
    }

    func test_textButton_action() throws {
        XCTAssertEqual(sut.textButtonViewModel.title.stringKey, "app_privacyNoticeLink")
        XCTAssertFalse(didCallTextButtonAction)
        sut.textButtonViewModel.action()
        XCTAssertTrue(didCallTextButtonAction)
        XCTAssertEqual(sut.textButtonViewModel.accessibilityHint, "app_externalBrowser")
    }
}
