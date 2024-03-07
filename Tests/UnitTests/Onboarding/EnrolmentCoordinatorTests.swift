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
    var mockLAContext: MockLAContext!
    var mockSecureStore: MockSecureStoreService!
    var mockDefaultsStore: MockDefaultsStore!
    var mockUserStore: MockUserStore!
    var tokenHolder: TokenHolder!
    var mockMainCoordinator: MainCoordinator!
    var sut: EnrolmentCoordinator!
    
    // swiftlint:disable line_length
    let accessTokenValue = "eEd2wTsYiaXEcZrXYoClvP9uZVvsSsJm4fw8haqSLcH8!B!i=U!/viQGDK3aQq/M2aUdwoxUqevzDX!A8NJFWrZ4VfLP/lgMGXdop=l2QtkLtBvP=iYAXCIBjtyP3i-bY5aP3lF4YLnldq02!jQWfxe1TvWesyMi9D1GIDq!X7JAJTMVHUIKH?-C18/-fcgkxHsQZhs/oFsW/56fTPsvdJPteu10nMF1gY0f8AChM6Yl5FAKX=UOdTHIoVJvf9Dt"
    // swiftlint:enable line_length
    
//    override func setUp() {
//        super.setUp()
//
//        window = .init()
//        navigationController = .init()
//        mockAnalyticsService = MockAnalyticsService()
//        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
//        mockAnalyticsCentre = AnalyticsCentre(analyticsService: mockAnalyticsService,
//                                              analyticsPreferenceStore: mockAnalyticsPreferenceStore)
//        mockLAContext = MockLAContext()
//        mockSecureStore = MockSecureStoreService()
//        mockDefaultsStore = MockDefaultsStore()
//        mockUserStore = MockUserStore(secureStoreService: mockSecureStore,
//                                      defaultsStore: mockDefaultsStore)
//        tokenHolder = TokenHolder()
//        mockMainCoordinator = MainCoordinator(window: window,
//                                              root: navigationController,
//                                              analyticsCentre: mockAnalyticsCentre,
//                                              secureStore: mockSecureStore,
//                                              defaultStore: mockDefaultsStore)
//        sut = EnrolmentCoordinator(root: navigationController,
//                                   localAuth: mockLAContext,
//                                   userStore: mockUserStore,
//                                   analyticsService: mockAnalyticsService,
//                                   tokenHolder: tokenHolder)
//    }
//
//    override func tearDown() {
//        window = nil
//        navigationController = nil
//        mockAnalyticsService = nil
//        mockAnalyticsPreferenceStore = nil
//        mockAnalyticsCentre = nil
//        mockLAContext = nil
//        mockSecureStore = nil
//        mockDefaultsStore = nil
//        mockUserStore = nil
//        tokenHolder = nil
//        mockMainCoordinator = nil
//        sut = nil
//
//        super.tearDown()
//    }
//
//    private enum LocalAuthError: Error {
//        case evident
//    }
}

/*
 TESTS
 - EnrolmentCoordinator start shows enrolment screens (faceid, touchid or passcode) and returninguser user defaults value set
 - EnrolmentCoordinator access token is stored in secure store and access token exp user defaults set
 - EnrolmentCoordinator if enrol local auth successful access token is stored in secure store and access token exp user defaults set
 */

fileprivate extension Date {
    static var accessTokenExp: Self {
        .init(timeIntervalSinceReferenceDate: 1729427067)
    }
}

extension EnrolmentCoordinatorTests {
//    func test_start_noDeviceLocalAuthSet() throws {
//        mockLAContext.returnedFromCanEvaluatePolicyForAuthentication = false
//        mockMainCoordinator.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
//        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
//        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
//        mockMainCoordinator.openChildInline(sut)
//        // THEN the view controller should be the information screen
//        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
//        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
//        XCTAssertTrue(vc.viewModel is PasscodeInformationViewModel)
//        // WHEN the button on the enrolment screen is tapped
//        let enrolmentPrimaryButton: UIButton = try XCTUnwrap(vc.view[child: "information-primary-button"])
//        enrolmentPrimaryButton.sendActions(for: .touchUpInside)
//        // THEN user is taken to the tokens screen
//        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
//        XCTAssertTrue(navigationController.topViewController is TokensViewController)
//        XCTAssertNil(mockDefaultsStore.savedData["accessTokenExpiry"])
//        XCTAssertEqual(mockDefaultsStore.savedData["returningUser"] as? Bool, true)
//        XCTAssertNil(mockSecureStore.savedItems["accessToken"])
//    }
//
//    func test_start_deviceLocalAuthSet_passcode() throws {
//        mockLAContext.returnedFromCanEvaluatePolicyForAuthentication = true
//        mockMainCoordinator.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
//        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
//        // GIVEN device passcode is set
//        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
//        mockMainCoordinator.openChildInline(sut)
//        // THEN the view controller should be the token screen
//        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
//        XCTAssertTrue(navigationController.topViewController is TokensViewController)
//        XCTAssertEqual(mockDefaultsStore.savedData["accessTokenExpiry"] as? Date, Date.accessTokenExp)
//        XCTAssertEqual(mockDefaultsStore.savedData["returningUser"] as? Bool, true)
//        XCTAssertEqual(mockSecureStore.savedItems["accessToken"], accessTokenValue)
//    }
//
//    func test_start_deviceLocalAuthSet_touchID_primaryButton() throws {
//        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
//        mockMainCoordinator.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
//        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
//        // GIVEN the user has enabled biometrics
//        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
//        mockMainCoordinator.openChildInline(sut)
//        // THEN the view controller should be the token screen
//        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
//        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
//        XCTAssertTrue(vc.viewModel is TouchIDEnrollmentViewModel)
//        // WHEN the button on the enrolment screen is tapped
//        let enrolmentPrimaryButton: UIButton = try XCTUnwrap(vc.view[child: "information-primary-button"])
//        enrolmentPrimaryButton.sendActions(for: .touchUpInside)
//        // THEN user is taken to the tokens screen
//        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
//        XCTAssertTrue(navigationController.topViewController is TokensViewController)
//        XCTAssertEqual(mockDefaultsStore.savedData["accessTokenExpiry"] as? Date, Date.accessTokenExp)
//        XCTAssertEqual(mockDefaultsStore.savedData["returningUser"] as? Bool, true)
//        XCTAssertEqual(mockSecureStore.savedItems["accessToken"], accessTokenValue)
//    }
//
//    func test_start_deviceLocalAuthSet_touchID_secondaryButton() throws {
//        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
//        mockMainCoordinator.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
//        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
//        // GIVEN the user has enabled biometrics
//        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
//        mockMainCoordinator.openChildInline(sut)
//        // THEN the view controller should be the token screen
//        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
//        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
//        XCTAssertTrue(vc.viewModel is TouchIDEnrollmentViewModel)
//        // WHEN the button on the enrolment screen is tapped
//        let enrolmentSecondaryButton: UIButton = try XCTUnwrap(vc.view[child: "information-secondary-button"])
//        enrolmentSecondaryButton.sendActions(for: .touchUpInside)
//        // THEN user is taken to the tokens screen
//        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
//        XCTAssertTrue(navigationController.topViewController is TokensViewController)
//        XCTAssertNil(mockDefaultsStore.savedData["accessTokenExpiry"])
//        XCTAssertEqual(mockDefaultsStore.savedData["returningUser"] as? Bool, true)
//        XCTAssertNil(mockSecureStore.savedItems["accessToken"])
//    }
//
//    func test_start_deviceLocalAuthSet_faceID_primaryButton_passed() throws {
//        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
//        mockMainCoordinator.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
//        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
//        mockLAContext.biometryType = .faceID
//        // GIVEN the user has enabled biometrics
//        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
//        mockMainCoordinator.openChildInline(sut)
//        // THEN the view controller should be the token screen
//        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
//        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
//        XCTAssertTrue(vc.viewModel is FaceIDEnrollmentViewModel)
//        // WHEN the button on the enrolment screen is tapped
//        let enrolmentPrimaryButton: UIButton = try XCTUnwrap(vc.view[child: "information-primary-button"])
//        enrolmentPrimaryButton.sendActions(for: .touchUpInside)
//        // THEN user is taken to the tokens screen
//        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
//        XCTAssertTrue(navigationController.topViewController is TokensViewController)
//        XCTAssertEqual(mockDefaultsStore.savedData["accessTokenExpiry"] as? Date, Date.accessTokenExp)
//        XCTAssertEqual(mockDefaultsStore.savedData["returningUser"] as? Bool, true)
//        XCTAssertEqual(mockSecureStore.savedItems["accessToken"], accessTokenValue)
//    }
//
//    func test_start_deviceLocalAuthSet_faceID_primaryButton_failed() throws {
//        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
//        mockLAContext.returnedFromEvaluatePolicy = false
//        tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
//        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
//        mockLAContext.biometryType = .faceID
//        // GIVEN the user has enabled biometrics
//        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
//        mockMainCoordinator.openChildInline(sut)
//        // THEN the view controller should be the token screen
//        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
//        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
//        XCTAssertTrue(vc.viewModel is FaceIDEnrollmentViewModel)
//        // WHEN the button on the enrolment screen is tapped
//        let enrolmentPrimaryButton: UIButton = try XCTUnwrap(vc.view[child: "information-primary-button"])
//        enrolmentPrimaryButton.sendActions(for: .touchUpInside)
//        // THEN user remains on the enrolment screen
//        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
//        XCTAssertTrue(navigationController.topViewController is GDSInformationViewController)
//        XCTAssertNil(mockDefaultsStore.savedData["accessTokenExpiry"])
//        XCTAssertEqual(mockDefaultsStore.savedData["returningUser"] as? Bool, true)
//        XCTAssertNil(mockSecureStore.savedItems["accessToken"])
//    }
//
//    func test_start_deviceLocalAuthSet_faceID_primaryButton_error() throws {
//        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
//        mockLAContext.errorFromEvaluatePolicy = LocalAuthError.evident
//        tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
//        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
//        mockLAContext.biometryType = .faceID
//        // GIVEN the user has enabled biometrics
//        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
//        mockMainCoordinator.openChildInline(sut)
//        // THEN the view controller should be the token screen
//        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
//        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
//        XCTAssertTrue(vc.viewModel is FaceIDEnrollmentViewModel)
//        // WHEN the button on the enrolment screen is tapped
//        let enrolmentPrimaryButton: UIButton = try XCTUnwrap(vc.view[child: "information-primary-button"])
//        enrolmentPrimaryButton.sendActions(for: .touchUpInside)
//        // THEN user remains on the enrolment screen
//        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
//        XCTAssertTrue(navigationController.topViewController is GDSInformationViewController)
//        XCTAssertNil(mockDefaultsStore.savedData["accessTokenExpiry"])
//        XCTAssertEqual(mockDefaultsStore.savedData["returningUser"] as? Bool, true)
//        XCTAssertNil(mockSecureStore.savedItems["accessToken"])
//    }
//
//    func test_start_deviceLocalAuthSet_faceID_secondaryButton() throws {
//        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
//        mockMainCoordinator.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
//        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
//        mockLAContext.biometryType = .faceID
//        // GIVEN the user has enabled biometrics
//        // WHEN the OnboardingCoordinator has shown the local auth guidance via start()
//        mockMainCoordinator.openChildInline(sut)
//        // THEN the view controller should be the token screen
//        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 2)
//        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
//        XCTAssertTrue(vc.viewModel is FaceIDEnrollmentViewModel)
//        // WHEN the button on the enrolment screen is tapped
//        let enrolmentSecondaryButton: UIButton = try XCTUnwrap(vc.view[child: "information-secondary-button"])
//        enrolmentSecondaryButton.sendActions(for: .touchUpInside)
//        // THEN user is taken to the tokens screen
//        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
//        XCTAssertTrue(navigationController.topViewController is TokensViewController)
//        XCTAssertNil(mockDefaultsStore.savedData["accessTokenExpiry"])
//        XCTAssertEqual(mockDefaultsStore.savedData["returningUser"] as? Bool, true)
//        XCTAssertNil(mockSecureStore.savedItems["accessToken"])
//    }
}
