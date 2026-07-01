import Coordination
import DesignSystem
import GDSCommon
import LocalAuthenticationWrapper
import Networking
@testable import OneLogin
import Wallet
import WalletInterface
import XCTest

@MainActor
final class LocalAuthServiceWalletTests: XCTestCase {
    var mockLocalAuthManager: MockLocalAuthManager!
    var mockAnalyticsService: MockAnalyticsService!
    var mockSessionManager: MockSessionManager!
    var sut: LocalAuthServiceWallet!
    var walletCoordinator: WalletCoordinator!
    
    var isEnrolled = false
    
    override func setUpWithError() throws {
        super.setUp()
        
        isEnrolled = false
        mockSessionManager = MockSessionManager()
        mockLocalAuthManager = try XCTUnwrap(
            mockSessionManager.localAuthentication as? MockLocalAuthManager
        )
        mockAnalyticsService = MockAnalyticsService()
       
        walletCoordinator =  WalletCoordinator(analyticsService: mockAnalyticsService,
                                               networkingService: NetworkClient(),
                                               sessionManager: mockSessionManager)
        sut = LocalAuthServiceWallet(walletCoordinator: walletCoordinator,
                                     analyticsService: mockAnalyticsService,
                                     sessionManager: mockSessionManager,
                                     localAuthentication: mockLocalAuthManager,
                                     enrolmentManager: MockEnrolmentManager.self)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        mockSessionManager = nil
        mockLocalAuthManager = nil
        walletCoordinator = nil
        sut = nil
        isEnrolled = false
        
        super.tearDown()
    }
}

enum WalletMockLocalAuthType: WalletLocalAuthType {
    case passcode
    case biometrics
    case none
}

struct MockEnrolmentManager: EnrolmentManager {
    let localAuthContext: LocalAuthManaging
    let sessionManager: SessionManager
    let analyticsService: OneLoginAnalyticsService
    weak var coordinator: ChildCoordinator?
    
    func saveSession(isWalletEnrolment: Bool, completion: (() -> Void)?) {
        completion?()
    }
    
    func completeEnrolment(isWalletEnrolment: Bool, completion: (() -> Void)?) {
        completion?()
    }
}

extension LocalAuthServiceWalletTests {
    func test_enrolLocalAuth() async throws {
        mockLocalAuthManager.type = .faceID
        
        sut.enrolLocalAuth(
            WalletMockLocalAuthType.biometrics,
            completion: {}
        )
        
        let vc = try XCTUnwrap(sut.biometricsNavigationController.topViewController as? GDSScreen)
        
        XCTAssertTrue(vc.viewModel is BiometricsEnrolmentViewModel)
    }
    
    func test_enrolLocalAuthPasscode() async throws {
        let exp = XCTestExpectation(description: "callback reached")
        
        XCTAssertFalse(isEnrolled)
        mockLocalAuthManager.type = .passcode
    
        sut.enrolLocalAuth(
            WalletMockLocalAuthType.biometrics,
            completion: {
                exp.fulfill()
            }
        )

        await fulfillment(of: [exp], timeout: 5)
    }
    
    func test_enrolLocalAuthNone() throws {
        XCTAssertFalse(isEnrolled)
        mockLocalAuthManager.type = .none
    
        sut.enrolLocalAuth(
            WalletMockLocalAuthType.biometrics,
            completion: {
                self.isEnrolled = true
            }
        )
        
        let vc = try XCTUnwrap(sut.biometricsNavigationController.topViewController as? GDSScreen)
        
        XCTAssertTrue(vc.viewModel is LocalAuthSettingsErrorViewModel)
        
        let secondErrorScreen = try XCTUnwrap(vc.viewModel as? LocalAuthSettingsErrorViewModel)
        
        secondErrorScreen.didDismiss?.perform()
        
        XCTAssertTrue(isEnrolled)
    }
    
    func test_isEnrolled_faceID() {
        mockLocalAuthManager.type = .faceID
        mockSessionManager.persistentID = "123456789"
        
        XCTAssertTrue(sut.isEnrolledToLocalAuth(LocalAuth.biometrics))
        XCTAssertTrue(sut.isEnrolledToLocalAuth(LocalAuth.passcode))
        XCTAssertTrue(sut.isEnrolledToLocalAuth(LocalAuth.none))
    }
    
    func test_isEnrolled_faceID_noPersistenID() {
        mockLocalAuthManager.type = .faceID
        mockSessionManager.persistentID = nil
        
        XCTAssertFalse(sut.isEnrolledToLocalAuth(LocalAuth.biometrics))
        XCTAssertFalse(sut.isEnrolledToLocalAuth(LocalAuth.passcode))
        XCTAssertFalse(sut.isEnrolledToLocalAuth(LocalAuth.none))
    }
    
    func test_isEnrolled_touchID() {
        mockLocalAuthManager.type = .touchID
        mockSessionManager.persistentID = "123456789"
        
        XCTAssertTrue(sut.isEnrolledToLocalAuth(LocalAuth.biometrics))
        XCTAssertTrue(sut.isEnrolledToLocalAuth(LocalAuth.passcode))
        XCTAssertTrue(sut.isEnrolledToLocalAuth(LocalAuth.none))
    }
    
    func test_isEnrolled_touchID_noPersistenID() {
        mockLocalAuthManager.type = .touchID
        mockSessionManager.persistentID = nil
        
        XCTAssertFalse(sut.isEnrolledToLocalAuth(LocalAuth.biometrics))
        XCTAssertFalse(sut.isEnrolledToLocalAuth(LocalAuth.passcode))
        XCTAssertFalse(sut.isEnrolledToLocalAuth(LocalAuth.none))
    }
    
    func test_isEnrolled_passcode() {
        mockLocalAuthManager.type = .passcode
        mockSessionManager.persistentID = "123456789"
        
        XCTAssertFalse(sut.isEnrolledToLocalAuth(LocalAuth.biometrics))
        XCTAssertTrue(sut.isEnrolledToLocalAuth(LocalAuth.passcode))
        XCTAssertTrue(sut.isEnrolledToLocalAuth(LocalAuth.none))
    }
    
    func test_isEnrolled_passcode_noPersistenID() {
        mockLocalAuthManager.type = .passcode
        mockSessionManager.persistentID = nil
        
        XCTAssertFalse(sut.isEnrolledToLocalAuth(LocalAuth.biometrics))
        XCTAssertFalse(sut.isEnrolledToLocalAuth(LocalAuth.passcode))
        XCTAssertFalse(sut.isEnrolledToLocalAuth(LocalAuth.none))
    }
    
    func test_isEnrolled_none_noPersistenID() {
        mockLocalAuthManager.type = .none
        
        XCTAssertFalse(sut.isEnrolledToLocalAuth(LocalAuth.biometrics))
        XCTAssertFalse(sut.isEnrolledToLocalAuth(LocalAuth.passcode))
        XCTAssertFalse(sut.isEnrolledToLocalAuth(LocalAuth.none))
    }
    
    func test_primaryButtonActionWithBiometrics() async throws {
        mockLocalAuthManager.type = .faceID
        
        XCTAssertFalse(isEnrolled)
        
        sut.enrolLocalAuth(
            WalletMockLocalAuthType.biometrics,
            completion: {
                self.isEnrolled = true
            }
        )
        
        let vc = try XCTUnwrap(sut.biometricsNavigationController.topViewController as? GDSScreen)
        let viewModel = try XCTUnwrap(vc.viewModel as? BiometricsEnrolmentViewModel)
        let primaryButton = viewModel.movableFooter[0] as? GDSButtonViewModel
        
        await primaryButton?.buttonAction.performAsync()
        
        XCTAssertTrue(isEnrolled)
    }
    
    func test_secondaryButtonActionWithBiometrics() async throws {
        mockLocalAuthManager.type = .faceID
        
        let enrolledExpectation = expectation(description: "User is Enrolled")
        
        XCTAssertFalse(isEnrolled)
        
        sut.enrolLocalAuth(
            WalletMockLocalAuthType.biometrics,
            completion: {
                self.isEnrolled = true
                enrolledExpectation.fulfill()
            }
        )
        
        let vc = try XCTUnwrap(sut.biometricsNavigationController.topViewController as? GDSScreen)
        let viewModel = try XCTUnwrap(vc.viewModel as? BiometricsEnrolmentViewModel)
        
        let secondaryButton = viewModel.movableFooter[1] as? GDSButtonViewModel
        secondaryButton?.buttonAction.perform()
        
        let vc2 = try XCTUnwrap(sut.biometricsNavigationController.topViewController as? GDSErrorScreen)
        
        XCTAssertTrue(vc2.viewModel is LocalAuthBiometricsErrorViewModel)
        
        let secondErrorScreen = try XCTUnwrap(vc2.viewModel)
        secondErrorScreen.buttonViewModels[0].action()
        
        await fulfillment(of: [enrolledExpectation], timeout: 5)
        
        XCTAssertTrue(isEnrolled)
    }
    
    // MARK: Tests ensuring biometricsNavigationController is presented
    func test_walletCoordinator_vcAlreadyBeingPresented_faceID() async throws {
        mockLocalAuthManager.type = .faceID
        
        let pushViewControllerExpectation = expectation(description: #function)
        pushViewControllerExpectation.expectedFulfillmentCount = 2
        
        let mockNavigationController = MockNavigationControllerExpectation(presentAsFunction: { _, _, _ in pushViewControllerExpectation.fulfill()})
        let walletCoordinator = WalletCoordinator(root: mockNavigationController,
                                                  analyticsService: mockAnalyticsService,
                                                  networkingService: NetworkClient(),
                                                  sessionManager: mockSessionManager)
        
        let sut = LocalAuthServiceWallet(walletCoordinator: walletCoordinator,
                                         analyticsService: mockAnalyticsService,
                                         sessionManager: mockSessionManager,
                                         localAuthentication: mockLocalAuthManager,
                                         enrolmentManager: MockEnrolmentManager.self)
        
        XCTAssertFalse(isEnrolled)
        
        let appWindow = UIWindow()
        appWindow.rootViewController = walletCoordinator.root
        appWindow.makeKeyAndVisible()
        
        // GIVEN walletCoordinator is presenting a ViewController
        let presentedVC = UIViewController()
        walletCoordinator.root.present(presentedVC, animated: false)
        
        XCTAssertNotNil(walletCoordinator.root.presentedViewController)
        
        // WHEN enrolment is attempted
        sut.enrolLocalAuth(
            WalletMockLocalAuthType.biometrics,
            completion: {
                self.isEnrolled = true
            }
        )
        
        let vc = try XCTUnwrap(sut.biometricsNavigationController.topViewController as? GDSScreen)
        let viewModel = try XCTUnwrap(vc.viewModel as? BiometricsEnrolmentViewModel)
        
        let primaryButton = viewModel.movableFooter[0] as? GDSButtonViewModel
        await primaryButton?.buttonAction.performAsync()
        
        await fulfillment(of: [pushViewControllerExpectation], timeout: 5)

        XCTAssertTrue(isEnrolled)
    }
    
    func test_walletCoordinator_vcAlreadyBeingPresented_touchID() async throws {
        mockLocalAuthManager.type = .touchID
        
        let pushViewControllerExpectation = expectation(description: #function)
        pushViewControllerExpectation.expectedFulfillmentCount = 2
        
        let mockNavigationController = MockNavigationControllerExpectation(presentAsFunction: { _, _, _ in pushViewControllerExpectation.fulfill()})
        let walletCoordinator = WalletCoordinator(root: mockNavigationController,
                                                  analyticsService: mockAnalyticsService,
                                                  networkingService: NetworkClient(),
                                                  sessionManager: mockSessionManager)
        
        let sut = LocalAuthServiceWallet(walletCoordinator: walletCoordinator,
                                         analyticsService: mockAnalyticsService,
                                         sessionManager: mockSessionManager,
                                         localAuthentication: mockLocalAuthManager,
                                         enrolmentManager: MockEnrolmentManager.self)
        
        XCTAssertFalse(isEnrolled)
        
        let appWindow = UIWindow()
        appWindow.rootViewController = walletCoordinator.root
        appWindow.makeKeyAndVisible()
        
        // GIVEN walletCoordinator is presenting a VC
        let presentedVC = UIViewController()
       
        walletCoordinator.root.present(presentedVC, animated: false)
        
        XCTAssertNotNil(walletCoordinator.root.presentedViewController)
        
        // WHEN enrolment is attempted
        sut.enrolLocalAuth(
            WalletMockLocalAuthType.biometrics,
            completion: {
                self.isEnrolled = true
            }
        )
        
        let vc = try XCTUnwrap(sut.biometricsNavigationController.topViewController as? GDSScreen)
        let viewModel = try XCTUnwrap(vc.viewModel as? BiometricsEnrolmentViewModel)
        
        let primaryButton = viewModel.movableFooter[0] as? GDSButtonViewModel
        await primaryButton?.buttonAction.performAsync()
        
        await fulfillment(of: [pushViewControllerExpectation], timeout: 5)

        XCTAssertTrue(isEnrolled)
    }
    
    func test_walletCoordinator_vcAlreadyBeingPresented_none() throws {
        mockLocalAuthManager.type = .none
        
        XCTAssertFalse(isEnrolled)
        
        let appWindow = UIWindow()
        appWindow.rootViewController = walletCoordinator.root
        appWindow.makeKeyAndVisible()
        
        // GIVEN walletCoordinator is presenting a VC
        let presentedVC = UIViewController()
       
        walletCoordinator.root.present(presentedVC, animated: false)
        
        XCTAssertNotNil(walletCoordinator.root.presentedViewController)
        
        sut.enrolLocalAuth(
            WalletMockLocalAuthType.biometrics,
            completion: {
                self.isEnrolled = true
            }
        )
        
        // THEN VC is dismissed and biometricsNavigationController is presented
        waitForTruth(self.walletCoordinator.root.presentedViewController == self.sut.biometricsNavigationController, timeout: 5)
        
        XCTAssertTrue(sut.biometricsNavigationController.topViewController is GDSScreen)
    }
}
