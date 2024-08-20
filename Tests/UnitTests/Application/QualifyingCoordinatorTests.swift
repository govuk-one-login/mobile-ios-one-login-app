@testable import OneLogin
import XCTest

@MainActor
final class QualifyingCoordinatorTests: XCTestCase {
    var navigationController: UINavigationController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockAnalyticsCenter: MockAnalyticsCenter!
    var mockSecureStore: MockSecureStoreService!
    var mockOpenSecureStore: MockSecureStoreService!
    var mockDefaultStore: MockDefaultsStore!
    var mockUserStore: UserStorage!
    var sut: QualifyingCoordinator!

    override func setUp() {
        super.setUp()

        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockAnalyticsCenter = MockAnalyticsCenter(analyticsService: mockAnalyticsService,
                                                  analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        mockSecureStore = MockSecureStoreService()
        mockOpenSecureStore = MockSecureStoreService()
        mockDefaultStore = MockDefaultsStore()
        mockUserStore = UserStorage(authenticatedStore: mockSecureStore,
                                    openStore: mockOpenSecureStore,
                                    defaultsStore: mockDefaultStore)
        sut = QualifyingCoordinator(userStore: mockUserStore, analyticsCenter: mockAnalyticsCenter)
    }

    override func tearDown() {
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCenter = nil
        sut = nil

        super.tearDown()
    }

    func returningAuthenticatedUser(expired: Bool = false) throws {
        TokenHolder.shared.tokenResponse = try MockTokenResponse().getJSONData(outdated: expired)
        try mockUserStore.saveItem(TokenHolder.shared.tokenResponse?.idToken,
                                   itemName: .idToken,
                                   storage: .authenticated)
        mockDefaultStore.set(TokenHolder.shared.tokenResponse?.expiryDate, forKey: .accessTokenExpiry)
        sut.idToken = try mockUserStore.readItem(itemName: .idToken,
                                                          storage: .authenticated)
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

//    func test_checkAppVersion() {
//
//    }

    func test_evaluateRevisit_newUser() throws {
        mockDefaultStore.set(nil, forKey: .accessTokenExpiry)
        sut.evaluateRevisit()
        XCTAssertNil(sut.idToken)
        XCTAssertThrowsError(try mockUserStore.readItem(itemName: .accessToken, storage: .authenticated))
    }

    func test_evaluateRevisit_notAuthenticatedUser() throws {
        // GIVEN the app has token information stored but the accessToken is expired
        try returningAuthenticatedUser(expired: true)
        // WHEN the QualifyingCoordinator's evaluateRevisit method is called
        sut.evaluateRevisit()
        // THEN the access and id tokens should be deleted; the app should require reauth
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .accessToken))
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .idToken))
        XCTAssertNotNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        XCTAssertNotNil(sut.idToken)
    }

    func test_evaluateRevisit_returningUser() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try returningAuthenticatedUser()
        // WHEN the QualifyingCoordinator's evaluateRevisit method is called
        sut.evaluateRevisit()
        // THEN the is token already should be stored in the token holder
        XCTAssertNotNil(sut.idToken)
    }
}
