import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class UpdateAppViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var urlOpener: MockURLOpener!
    var sut: UpdateAppViewModel!

    override func setUp() {
        super.setUp()

        mockAnalyticsService = MockAnalyticsService()
        urlOpener = .init()
        sut = UpdateAppViewModel(analyticsService: mockAnalyticsService,
                                 urlOpener: urlOpener)
    }

    override func tearDown() {
        mockAnalyticsService = nil
        urlOpener = nil
        sut = nil

        super.tearDown()
    }
}

extension UpdateAppViewModelTests {
    func test_page() {
        XCTAssertEqual(sut.imageWeight, .regular)
        XCTAssertEqual(sut.image, "exclamationmark.arrow.circlepath")
        XCTAssertEqual(sut.title.stringKey, "app_updateAppTitle")
        XCTAssertEqual(sut.title.value, "You need to update your app")
        XCTAssertEqual(sut.body?.stringKey, "app_updateAppBody")
        XCTAssertEqual(sut.body?.variableKeys, ["app_nameString"])
        XCTAssertEqual(sut.body?.value, "You’re using an old version of the GOV.UK One Login app.\n\nUpdate your app to continue.")
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }

    func test_button() {
        XCTAssertEqual(sut.primaryButtonViewModel.title.stringKey, "app_updateAppButton")
        XCTAssertEqual(sut.primaryButtonViewModel.title.variableKeys, ["app_nameString"])
        XCTAssertEqual(sut.primaryButtonViewModel.title.value, "Update GOV.UK One Login app")
        XCTAssertEqual(sut.primaryButtonViewModel.accessibilityHint?.stringKey, "app_externalApp")
        XCTAssertFalse(urlOpener.didOpenURL)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(urlOpener.didOpenURL)
        
        let event = LinkEvent(textKey: "app_updateAppButton",
                              variableKeys: "app_nameString",
                              linkDomain: AppEnvironment.appStore.absoluteString,
                              external: .true)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String, OLTaxonomyValue.system)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String, OLTaxonomyValue.undefined)
    }
}
