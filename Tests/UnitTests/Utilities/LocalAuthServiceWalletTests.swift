import Networking
@testable import OneLogin
import Wallet
import XCTest

@MainActor
final class LocalAuthServiceWalletTests: XCTestCase {
    var localAuthentication: MockLocalAuthManager!
    var mockAnalyticsService: MockAnalyticsService!
    var mockSessionManager: MockSessionManager!
    var sut: WalletLocalAuthService!
    
    var didEnrol = false
    
    override func setUp() {
        super.setUp()
        
        localAuthentication = MockLocalAuthManager()
        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()
        sut = LocalAuthServiceWallet(walletCoordinator: WalletCoordinator(analyticsService: mockAnalyticsService,
                                                                          networkClient: NetworkClient(),
                                                                          sessionManager: mockSessionManager),
                                     analyticsService: mockAnalyticsService,
                                     sessionManager: mockSessionManager,
                                     localAuthentication: localAuthentication)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        mockSessionManager = nil
        localAuthentication = nil
        sut = nil
        
        didEnrol = false
        
        super.tearDown()
    }
}

enum WalletMockLocalAuthType: WalletLocalAuthType {
    case passcode
    case biometrics
    case none
}

extension LocalAuthServiceWalletTests {
    func test_enrolLocalAuth() {
        XCTAssertFalse(didEnrol)
        
        sut.enrolLocalAuth(
            WalletMockLocalAuthType.biometrics,
            completion: {
                self.didEnrol = true
            }
        )
        
        XCTAssertTrue(didEnrol)
    }
    
    func test_isEnrolled() {
        XCTAssertTrue(sut.isEnrolled(WalletMockLocalAuthType.biometrics))
    }
    
    func test_isEnrolledFalse() {
        XCTAssertTrue(sut.isEnrolled(WalletMockLocalAuthType.none))
    }
}
