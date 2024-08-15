@testable import OneLogin
import XCTest

@MainActor
final class QualifyingCoordinatorTests: XCTestCase {
    var navigationController: UINavigationController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockAnalyticsCenter: MockAnalyticsCenter!
    var sut: QualifyingCoordinator!

    override func setUp() {
        super.setUp()

        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockAnalyticsCenter = MockAnalyticsCenter(analyticsService: mockAnalyticsService,
                                                  analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        sut = QualifyingCoordinator(analyticsCenter: mockAnalyticsCenter)
    }

    override func tearDown() {
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCenter = nil
        sut = nil

        super.tearDown()
    }
}

extension QualifyingCoordinatorTests {
    func test_start() {
        // WHEN the QualifyingCoordinator is started
        sut.start()
        // THEN the visible view controller should be the UnlockScreenViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is UnlockScreenViewController)
    }
}
