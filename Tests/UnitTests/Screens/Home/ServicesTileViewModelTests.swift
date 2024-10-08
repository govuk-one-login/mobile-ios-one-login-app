import GDSAnalytics
import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class ServicesTileViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: ServicesTileViewModel!
    
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = ServicesTileViewModel(analyticsService: mockAnalyticsService) {
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

extension ServicesTileViewModelTests {
    func test_view_contents() throws {
        XCTAssertEqual(sut.title.stringKey, "app_yourServicesCardTitle")
        XCTAssertEqual(sut.body.stringKey, "app_yourServicesCardBody")
        XCTAssertTrue(sut.secondaryButtonViewModel is AnalyticsButtonViewModel)
        XCTAssertEqual(sut.secondaryButtonViewModel.title.stringKey, "app_yourServicesCardLink")
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
        let event = LinkEvent(textKey: "app_yourServicesCardLink",
                              linkDomain: AppEnvironment.yourServicesLink,
                              external: .false)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
    
    func test_yourServices_viewModel() {
        let mockURLOpener = MockURLOpener()
        let yourServicesTileViewModel: ServicesTileViewModel = .yourServices(analyticsService: mockAnalyticsService,
                                                                             urlOpener: mockURLOpener)
        yourServicesTileViewModel.secondaryButtonViewModel.action()
        XCTAssertTrue(mockURLOpener.didOpenURL)
    }
}
