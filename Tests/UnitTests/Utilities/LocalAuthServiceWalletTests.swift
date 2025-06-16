import GDSCommon
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
    
    override func setUp() {
        super.setUp()
        
        mockLocalAuthManager = MockLocalAuthManager()
        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()
        walletCoordinator =  WalletCoordinator(analyticsService: mockAnalyticsService,
                                               networkClient: NetworkClient(),
                                               sessionManager: mockSessionManager)
        navigationController = walletCoordinator.root
        sut = LocalAuthServiceWallet(walletCoordinator: walletCoordinator,
                                     analyticsService: mockAnalyticsService,
                                     sessionManager: mockSessionManager,
                                     localAuthentication: mockLocalAuthManager)
    }
    
    override func tearDown() {
        navigationController = nil
        mockAnalyticsService = nil
        mockSessionManager = nil
        mockLocalAuthManager = nil
        walletCoordinator = nil
        sut = nil
        
        super.tearDown()
    }
}

enum WalletMockLocalAuthType: WalletLocalAuthType {
    case passcode
    case biometrics
    case none
}

extension LocalAuthServiceWalletTests {
    func test_enrolLocalAuth() throws {
        mockLocalAuthManager.type = .faceID
        
        sut.enrolLocalAuth(
            WalletMockLocalAuthType.biometrics,
            completion: {}
        )
        
        XCTAssertNotNil(sut.biometricsEnrolmentScreen)
    }
    
    func test_isEnrolled() {
        XCTAssertTrue(sut.isEnrolled(WalletMockLocalAuthType.biometrics))
    }
    
    func test_isEnrolledFalse() {
        XCTAssertTrue(sut.isEnrolled(WalletMockLocalAuthType.none))
    }
}
