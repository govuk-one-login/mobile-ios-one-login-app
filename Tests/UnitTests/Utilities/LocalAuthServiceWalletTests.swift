import Coordination
import GDSCommon
import LocalAuthenticationWrapper
import Networking
@testable import OneLogin
import Wallet
import WalletInterface
import XCTest

@MainActor
final class LocalAuthServiceWalletTests: XCTestCase {
    private var navigationController: UINavigationController!
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
                                               networkClient: NetworkClient(),
                                               sessionManager: mockSessionManager)
        navigationController = walletCoordinator.root
        sut = LocalAuthServiceWallet(walletCoordinator: walletCoordinator,
                                     analyticsService: mockAnalyticsService,
                                     sessionManager: mockSessionManager,
                                     localAuthentication: mockLocalAuthManager,
                                     enrolmentManager: MockEnrolmentManager.self)
    }
    
    override func tearDown() {
        navigationController = nil
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
        
        let vc = try XCTUnwrap(sut.biometricsNavigationController.topViewController as? GDSInformationViewController)
        
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
        
        let vc = try XCTUnwrap(sut.biometricsNavigationController.topViewController as? GDSErrorScreen)
        
        XCTAssertTrue(vc.viewModel is LocalAuthSettingsErrorViewModel)
        
        let secondErrorScreen = try XCTUnwrap(vc.viewModel)
        
        secondErrorScreen.buttonViewModels[0].action()
        
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
    
    func test_primaryButtonActionWithBiometrics() throws {
        mockLocalAuthManager.type = .faceID
        
        XCTAssertFalse(isEnrolled)
        
        sut.enrolLocalAuth(
            WalletMockLocalAuthType.biometrics,
            completion: {
                self.isEnrolled = true
            }
        )
        
        let vc = try XCTUnwrap(sut.biometricsNavigationController.topViewController as? GDSInformationViewController)
        
        let viewModel = try XCTUnwrap(vc.viewModel as? GDSCentreAlignedViewModelWithPrimaryButton & GDSCentreAlignedViewModelWithSecondaryButton)
        
        viewModel.primaryButtonViewModel.action()
        
        XCTAssertTrue(isEnrolled)
    }
    
    func test_secondaryButtonActionWithBiometrics() throws {
        mockLocalAuthManager.type = .faceID
        
        XCTAssertFalse(isEnrolled)
        
        sut.enrolLocalAuth(
            WalletMockLocalAuthType.biometrics,
            completion: {
                self.isEnrolled = true
            }
        )
        
        let vc = try XCTUnwrap(sut.biometricsNavigationController.topViewController as? GDSInformationViewController)
        
        let viewModel = try XCTUnwrap(vc.viewModel as? GDSCentreAlignedViewModelWithPrimaryButton & GDSCentreAlignedViewModelWithSecondaryButton)
        
        viewModel.secondaryButtonViewModel.action()
        
        let vc2 = try XCTUnwrap(sut.biometricsNavigationController.topViewController as? GDSErrorScreen)
        
        XCTAssertTrue(vc2.viewModel is LocalAuthBiometricsErrorViewModel)
        
        let secondErrorScreen = try XCTUnwrap(vc2.viewModel)
        
        secondErrorScreen.buttonViewModels[0].action()
        
        XCTAssertTrue(isEnrolled)
    }
}
