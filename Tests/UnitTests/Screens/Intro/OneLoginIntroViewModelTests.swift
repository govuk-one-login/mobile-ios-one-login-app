@testable import DesignSystem
import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class OneLoginIntroViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: OneLoginIntroViewModel!
    
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = OneLoginIntroViewModel(analyticsService: mockAnalyticsService) {
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

extension OneLoginIntroViewModelTests {
    func test_page() throws {
        let imageVM = try XCTUnwrap(sut.body.first as? GDSImageViewModel)
        let titleText = try XCTUnwrap(sut.body[1] as? GDSTextViewModel)
        let bodyText = try XCTUnwrap(sut.body[2] as? GDSTextViewModel)
        XCTAssertEqual(imageVM.image, UIImage(named: "badge"))
        XCTAssertEqual(titleText.title.stringKey, "app_nameString")
        XCTAssertEqual(titleText.title.value, "GOV.UK One Login")
        XCTAssertEqual(bodyText.title.stringKey, "app_signInBody")
        XCTAssertEqual(bodyText.title.variableKeys, ["app_nameString"])
        XCTAssertEqual(bodyText.title.value, "Prove your identity to access government services.\n\nYou’ll need to sign in with your GOV.UK One Login details.")
    }
    
    func test_button() throws {
        let primaryButton = try XCTUnwrap(sut.movableFooter.first as? GDSButtonViewModel)
        XCTAssertEqual(primaryButton.title.forState(.normal), "Sign in with GOV.UK One Login")
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        let button = GDSButton(viewModel: primaryButton)
        button.simulateEvent(.touchUpInside)
        XCTAssertTrue(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = LinkEvent(textKey: "app_extendedSignInButton",
                              variableKeys: "app_nameString",
                              linkDomain: AppEnvironment.mobileBaseURLString,
                              external: .false)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
    
    func test_didAppear() {
        XCTAssertNil(sut.didDismiss)
        XCTAssertEqual(mockAnalyticsService.screenViews.count, 0)
        let vc = GDSScreen(viewModel: sut)
        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()
        XCTAssertEqual(mockAnalyticsService.screenViews.count, 1)
        let screen = ScreenView(id: IntroAnalyticsScreenID.welcome.rawValue,
                                screen: IntroAnalyticsScreen.welcome,
                                titleKey: "app_nameString")
        XCTAssertEqual(mockAnalyticsService.screenViews as? [ScreenView], [screen])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
}
