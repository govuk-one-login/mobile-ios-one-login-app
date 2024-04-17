import Authentication
import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class EnrolmentCoordinatorTests: XCTestCase {
    var navigationController: UINavigationController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockSecureStore: MockSecureStoreService!
    var mockDefaultsStore: MockDefaultsStore!
    var mockUserStore: MockUserStore!
    var mockLAContext: MockLAContext!
    var tokenHolder: TokenHolder!
    var sut: EnrolmentCoordinator!
    
    override func setUp() {
        super.setUp()

        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockSecureStore = MockSecureStoreService()
        mockDefaultsStore = MockDefaultsStore()
        mockUserStore = MockUserStore(secureStoreService: mockSecureStore,
                                      defaultsStore: mockDefaultsStore)
        mockLAContext = MockLAContext()
        tokenHolder = TokenHolder()
        sut = EnrolmentCoordinator(root: navigationController,
                                   analyticsService: mockAnalyticsService,
                                   userStore: mockUserStore,
                                   localAuth: mockLAContext,
                                   tokenHolder: tokenHolder)
    }

    override func tearDown() {
        navigationController = nil
        mockAnalyticsService = nil
        mockSecureStore = nil
        mockDefaultsStore = nil
        mockUserStore = nil
        mockLAContext = nil
        tokenHolder = nil
        sut = nil

        super.tearDown()
    }

    private enum LocalAuthError: Error {
        case generic
    }
    
    private enum SecureStoreError: Error {
        case generic
    }
}

fileprivate extension Date {
    static var accessTokenExp: Self {
        .init(timeIntervalSinceReferenceDate: 1729427067)
    }
}

extension EnrolmentCoordinatorTests {
    func test_start_noDeviceLocalAuthSet() throws {
        // GIVEN the local authentication context returned true for canEvaluatePolicy for authentication
        mockLAContext.returnedFromCanEvaluatePolicyForAuthentication = false
        // GIVEN the token holder's token response has tokens
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the 'passcode information' screen is shown
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is PasscodeInformationViewModel)
    }

    func test_start_deviceLocalAuthSet_passcode_succeeds() throws {
        // GIVEN the local authentication context returned true for canEvaluatePolicy for authentication
        mockLAContext.returnedFromCanEvaluatePolicyForAuthentication = true
        // GIVEN the token holder's token response has tokens
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the journey should be saved in user defaults
        XCTAssertEqual(mockDefaultsStore.savedData["accessTokenExpiry"] as? Date, Date.accessTokenExp)
        XCTAssertEqual(mockSecureStore.savedItems["accessToken"], "accessTokenResponse")
    }

    func test_start_deviceLocalAuthSet_passcode_fails() throws {
        // GIVEN the local authentication context returned true for canEvaluatePolicy for authentication
        mockLAContext.returnedFromCanEvaluatePolicyForAuthentication = true
        // GIVEN the secure store returns an error from saving an item
        mockSecureStore.errorFromSaveItem = SecureStoreError.generic
        // GIVEN the token holder's token response has tokens
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the journey should be saved in user defaults
        XCTAssertEqual(mockDefaultsStore.savedData["accessTokenExpiry"] as? Date, nil)
        XCTAssertEqual(mockSecureStore.savedItems["accessToken"], nil)
    }

    func test_start_deviceLocalAuthSet_touchID() throws {
        // GIVEN the local authentication context returned true for canEvaluatePolicy for biometrics
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        // GIVEN the token holder's token response has tokens
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the 'touch id information' screen is shown
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is TouchIDEnrollmentViewModel)
    }

    func test_start_deviceLocalAuthSet_faceID() throws {
        // GIVEN the local authentication context returned true for canEvaluatePolicy for biometrics
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        // GIVEN the token holder's token response has tokens
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        // GIVEN the local authentication's biometry type is face id
        mockLAContext.biometryType = .faceID
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the 'face id information' screen is shown
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is FaceIDEnrollmentViewModel)
    }
    
    func test_start_deviceLocalAuthSet_opticID() throws {
        // GIVEN the local authentication context returned true for canEvaluatePolicy for biometrics
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        // GIVEN the token holder's token response has tokens
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        // GIVEN the local authentication's biometry type is optic id
        if #available(iOS 17.0, *) {
            mockLAContext.biometryType = .opticID
        }
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the no screen is shown
        XCTAssertEqual(navigationController.viewControllers.count, 0)
    }
    
    func test_enrolLocalAuth_succeeds() throws {
        // GIVEN the local authentication context returned true for evaluatePolicy
        mockLAContext.returnedFromEvaluatePolicy = true
        // GIVEN the token holder's token response has tokens
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        // WHEN the EnrolmentCoordinator's enrolLocalAuth method is called
        Task { await sut.enrolLocalAuth(reason: "") }
        // THEN the journey should be saved in user defaults
        waitForTruth(self.mockDefaultsStore.savedData["accessTokenExpiry"] as? Date == Date.accessTokenExp, timeout: 20)
        XCTAssertEqual(mockSecureStore.savedItems["accessToken"], "accessTokenResponse")
        XCTAssertEqual(mockLAContext.localizedFallbackTitle, "Enter passcode")
        XCTAssertEqual(mockLAContext.localizedCancelTitle, "Cancel")
    }
    
    func test_enrolLocalAuth_fails() throws {
        // GIVEN the local authentication context returned false for evaluatePolicy
        mockLAContext.returnedFromEvaluatePolicy = false
        // GIVEN the token holder's token response has tokens
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        // WHEN the EnrolmentCoordinator's enrolLocalAuth method is called
        Task { await sut.enrolLocalAuth(reason: "") }
        // THEN the journey should be saved in user defaults
        waitForTruth(self.mockDefaultsStore.savedData["accessTokenExpiry"] as? Date == nil, timeout: 20)
        XCTAssertEqual(mockSecureStore.savedItems["accessToken"], nil)
    }
    
    func test_enrolLocalAuth_errors() throws {
        // GIVEN the local authentication context returned an error for evaluatePolicy
        mockLAContext.errorFromEvaluatePolicy = LocalAuthError.generic
        // GIVEN the token holder's token response has tokens
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        // WHEN the EnrolmentCoordinator's enrolLocalAuth method is called
        Task { await sut.enrolLocalAuth(reason: "") }
        // THEN the journey should be saved in user defaults
        waitForTruth(self.mockDefaultsStore.savedData["accessTokenExpiry"] as? Date == nil, timeout: 20)
        XCTAssertEqual(mockSecureStore.savedItems["accessToken"], nil)
    }
}
