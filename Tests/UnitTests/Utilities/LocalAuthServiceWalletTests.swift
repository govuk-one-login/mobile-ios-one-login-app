import Coordination
import GDSCommon
import LocalAuthenticationWrapper
import Networking
@testable import OneLogin
import Wallet
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
        
        XCTAssertNotNil(sut.biometricsEnrolmentScreen)
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

        XCTAssertTrue(isEnrolled)
    }
    
    func test_isEnrolled() {
        XCTAssertTrue(sut.isEnrolled(WalletMockLocalAuthType.biometrics))
    }
    
    func test_isEnrolledFalse() {
        XCTAssertTrue(sut.isEnrolled(WalletMockLocalAuthType.none))
    }
    
    func test_primaryButtonAction() throws {
        mockLocalAuthManager.type = .faceID
        
        XCTAssertFalse(isEnrolled)
        
        sut.enrolLocalAuth(
            WalletMockLocalAuthType.biometrics,
            completion: {
                self.isEnrolled = true
            }
        )
        
        let screen = try XCTUnwrap(sut.biometricsEnrolmentScreen?.viewModel as? GDSCentreAlignedViewModelWithPrimaryButton & GDSCentreAlignedViewModelWithSecondaryButton)
        
        screen.primaryButtonViewModel.action()
        
        XCTAssertTrue(isEnrolled)
    }
    
    func test_secondaryButtonAction() throws {
        mockLocalAuthManager.type = .faceID
        
        XCTAssertFalse(isEnrolled)
        
        sut.enrolLocalAuth(
            WalletMockLocalAuthType.biometrics,
            completion: {
                self.isEnrolled = true
            }
        )
        
        let screen = try XCTUnwrap(sut.biometricsEnrolmentScreen?.viewModel as? GDSCentreAlignedViewModelWithPrimaryButton & GDSCentreAlignedViewModelWithSecondaryButton)
        
        screen.secondaryButtonViewModel.action()
        
        XCTAssertTrue(isEnrolled)
    }
}
