import GDSAnalytics
@testable import OneLogin
import XCTest

final class TouchIDEnrollmentViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: TouchIDEnrollmentViewModel!
    var didCallPrimaryButtonAction = false
    var didCallSecondaryButtonAction = false

    override func setUp() {
        super.setUp()

        mockAnalyticsService = MockAnalyticsService()
        sut = TouchIDEnrollmentViewModel(analyticsService: mockAnalyticsService) {
            self.didCallPrimaryButtonAction = true
        } secondaryButtonAction: {
            self.didCallSecondaryButtonAction = true
        }
    }

    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        didCallPrimaryButtonAction = false
        didCallSecondaryButtonAction = false

        super.tearDown()
    }
}

extension TouchIDEnrollmentViewModelTests {
    func test_label_contents() throws {
        XCTAssertEqual(sut.image, "touchid")
        XCTAssertEqual(sut.title.value, "Use Touch ID to sign in")
        XCTAssertEqual(sut.body?.value, """
    Add a layer of security and sign in with your fingerprint instead of your email address and password. Your Touch ID is not shared with GOV.UK One Login.\n
    If you do not want to use Touch ID, you can sign in with your phone passcode instead.
    """)
    }

    func test_primaryButton_action() throws {
        XCTAssertFalse(didCallPrimaryButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallPrimaryButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: sut.primaryButtonViewModel.title.value)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], event.parameters["text"])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["type"], event.parameters["type"])
    }

    func test_secondaryButton_action() throws {
        XCTAssertFalse(didCallSecondaryButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.secondaryButtonViewModel?.action()
        XCTAssertTrue(didCallSecondaryButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: sut.secondaryButtonViewModel?.title.value ?? "No value")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], event.parameters["text"])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["type"], event.parameters["type"])
    }

    func test_didAppear() throws {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(screen: BiometricEnrollmentAnalyticsScreen.touchIDEnrollment, titleKey: "use touch id to sign in")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [ screen.screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["title"], screen.parameters["title"])
    }
}
