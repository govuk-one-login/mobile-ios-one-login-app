import Authentication
import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class EnrolmentCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var navigationController: UINavigationController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockAnalyticsCentre: AnalyticsCentral!
    var mockSecureStore: MockSecureStoreService!
    var mockDefaultsStore: MockDefaultsStore!
    var mockUserStore: MockUserStore!
    var mockLAContext: MockLAContext!
    var tokenHolder: TokenHolder!
    var sut: EnrolmentCoordinator!
    
    // swiftlint:disable line_length
    let accessTokenValue = "eEd2wTsYiaXEcZrXYoClvP9uZVvsSsJm4fw8haqSLcH8!B!i=U!/viQGDK3aQq/M2aUdwoxUqevzDX!A8NJFWrZ4VfLP/lgMGXdop=l2QtkLtBvP=iYAXCIBjtyP3i-bY5aP3lF4YLnldq02!jQWfxe1TvWesyMi9D1GIDq!X7JAJTMVHUIKH?-C18/-fcgkxHsQZhs/oFsW/56fTPsvdJPteu10nMF1gY0f8AChM6Yl5FAKX=UOdTHIoVJvf9Dt"
    // swiftlint:enable line_length
    
    override func setUp() {
        super.setUp()

        window = .init()
        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockAnalyticsCentre = AnalyticsCentre(analyticsService: mockAnalyticsService,
                                              analyticsPreferenceStore: mockAnalyticsPreferenceStore)
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
        window = nil
        navigationController = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCentre = nil
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

/*
 TESTS
 - EnrolmentCoordinator start shows enrolment screens (faceid, touchid or passcode) and returninguser user defaults value set
 - EnrolmentCoordinator access token is stored in secure store and access token exp user defaults set
 - EnrolmentCoordinator if enrol local auth successful access token is stored in secure store and access token exp user defaults set
 */

extension EnrolmentCoordinatorTests {
    func test_start_noDeviceLocalAuthSet() throws {
        mockLAContext.returnedFromCanEvaluatePolicyForAuthentication = false
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
        sut.start()
        // THEN the view controller should be the information screen
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is PasscodeInformationViewModel)
    }

    func test_start_deviceLocalAuthSet_passcode_succeeds() throws {
        mockLAContext.returnedFromCanEvaluatePolicyForAuthentication = true
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        // GIVEN device passcode is set
        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
        sut.start()
        // THEN the view controller should be the token screen
        XCTAssertEqual(mockDefaultsStore.savedData["accessTokenExpiry"] as? Date, Date.accessTokenExp)
        XCTAssertEqual(mockDefaultsStore.savedData["returningUser"] as? Bool, true)
        XCTAssertEqual(mockSecureStore.savedItems["accessToken"], accessTokenValue)
    }

    func test_start_deviceLocalAuthSet_passcode_fails() throws {
        mockLAContext.returnedFromCanEvaluatePolicyForAuthentication = true
        mockSecureStore.errorFromSaveItem = SecureStoreError.generic
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        // GIVEN device passcode is set
        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
        sut.start()
        // THEN the view controller should be the token screen
        XCTAssertEqual(mockDefaultsStore.savedData["accessTokenExpiry"] as? Date, nil)
        XCTAssertEqual(mockDefaultsStore.savedData["returningUser"] as? Bool, true)
        XCTAssertEqual(mockSecureStore.savedItems["accessToken"], nil)
    }

    func test_start_deviceLocalAuthSet_touchID() throws {
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        // GIVEN the user has enabled biometrics
        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
        sut.start()
        // THEN the view controller should be the token screen
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is TouchIDEnrollmentViewModel)
    }

    func test_start_deviceLocalAuthSet_faceID() throws {
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        mockLAContext.biometryType = .faceID
        // GIVEN the user has enabled biometrics
        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
        sut.start()
        // THEN the view controller should be the token screen
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is FaceIDEnrollmentViewModel)
    }
}
