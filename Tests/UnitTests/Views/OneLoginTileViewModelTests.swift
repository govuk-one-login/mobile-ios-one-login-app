import GDSAnalytics
import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class OneLoginTileViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: OneLoginTileViewModel!
    
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = OneLoginTileViewModel(analyticsService: mockAnalyticsService) {
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

extension OneLoginTileViewModelTests {
    func test_view_contents() throws {
        XCTAssertEqual(sut.title.value, "Using your GOV.UK One Login")
        XCTAssertEqual(sut.body.value, "Sign in to your GOV.UK One Login and read about the services you can use with it.")
        XCTAssertTrue(sut.secondaryButtonViewModel is AnalyticsButtonViewModel)
        XCTAssertEqual(sut.secondaryButtonViewModel.title.value, "Go to the GOV.UK website")
        XCTAssertEqual(sut.secondaryButtonViewModel.icon?.iconName, ButtonIcon.arrowUpRight)
        XCTAssertEqual(sut.secondaryButtonViewModel.icon?.symbolPosition, .afterTitle)
        XCTAssertTrue(sut.showSeparatorLine)
        XCTAssertEqual(sut.backgroundColour, .secondarySystemGroupedBackground)
    }
    
    func test_button_action() throws {
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.secondaryButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = LinkEvent(textKey: "app_oneLoginCardLink",
                              linkDomain: AppEnvironment.manageAccountURL.absoluteString,
                              external: .false)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
    
    func test_oneLogin_viewModel() {
        let mockURLOpener = MockURLOpener()
        let oneLoginTileViewModel: OneLoginTileViewModel = .oneLoginCard(analyticsService: mockAnalyticsService,
                                                                         urlOpener: mockURLOpener)
        oneLoginTileViewModel.secondaryButtonViewModel.action()
        XCTAssertTrue(mockURLOpener.didOpenURL)
    }
}
