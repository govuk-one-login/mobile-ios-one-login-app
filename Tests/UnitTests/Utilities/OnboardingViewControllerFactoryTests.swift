import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class OnboardingViewControllerFactoryTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: OnboardingViewControllerFactory.Type!
    var didCallPrimaryAction = false
    var didCallSecondaryAction = false
    var didCallTextAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = OnboardingViewControllerFactory.self
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        didCallPrimaryAction = false
        didCallSecondaryAction = false
        didCallTextAction = false
        super.tearDown()
    }
}

extension OnboardingViewControllerFactoryTests {
    func test_analytics_callsAction() throws {
        let analyticsView = sut.createAnalyticsPeferenceScreen {
            self.didCallPrimaryAction = true
        } secondaryButtonAction: {
            self.didCallSecondaryAction = true
        } textButtonAction: {
            self.didCallTextAction = true
        }
        let analyticsPrimaryButton: UIButton = try XCTUnwrap(analyticsView.view[child: "modal-info-primary-button"])
        analyticsPrimaryButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallPrimaryAction)
        let analyticsSecondaryButton: UIButton = try XCTUnwrap(analyticsView.view[child: "modal-info-secondary-button"])
        analyticsSecondaryButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallSecondaryAction)
        let analyticsTextButton: UIButton = try XCTUnwrap(analyticsView.view[child: "modal-info-text-button"])
        analyticsTextButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallTextAction)
    }
    
    func test_passcode_callsAction() throws {
        let passcodeView = sut.createPasscodeInformationScreen(analyticsService: mockAnalyticsService) {
            self.didCallPrimaryAction = true
        }
        let passcodeButton: UIButton = try XCTUnwrap(passcodeView.view[child: "information-primary-button"])
        passcodeButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallPrimaryAction)
    }
    
    func test_touchID_callsAction() throws {
        let touchIDView = sut.createTouchIDEnrollmentScreen(analyticsService: mockAnalyticsService) {
            self.didCallPrimaryAction = true
        } secondaryButtonAction: {
            self.didCallSecondaryAction = true
        }
        let touchIDPrimaryButton: UIButton = try XCTUnwrap(touchIDView.view[child: "information-primary-button"])
        touchIDPrimaryButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallPrimaryAction)
        let touchIDSecondaryButton: UIButton = try XCTUnwrap(touchIDView.view[child: "information-secondary-button"])
        touchIDSecondaryButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallSecondaryAction)
    }
    
    func test_faceID_callsAction() throws {
        let faceIDView = sut.createTouchIDEnrollmentScreen(analyticsService: mockAnalyticsService) {
            self.didCallPrimaryAction = true
        } secondaryButtonAction: {
            self.didCallSecondaryAction = true
        }
        let faceIDPrimaryButton: UIButton = try XCTUnwrap(faceIDView.view[child: "information-primary-button"])
        faceIDPrimaryButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallPrimaryAction)
        let faceIDSecondaryButton: UIButton = try XCTUnwrap(faceIDView.view[child: "information-secondary-button"])
        faceIDSecondaryButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallSecondaryAction)
    }
}
