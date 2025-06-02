import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class DataDeletedWarningViewModelTests: XCTestCase {
    var sut: DataDeletedWarningViewModel!
    
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        sut = DataDeletedWarningViewModel {
            self.didCallButtonAction = true
        }
    }
    
    override func tearDown() {
        sut = nil
        
        didCallButtonAction = false
        
        AppEnvironment.updateFlags(
            releaseFlags: [:],
            featureFlags: [:]
        )
        
        super.tearDown()
    }
}

extension DataDeletedWarningViewModelTests {
    func test_pageNoWallet() {
        AppEnvironment.updateFlags(
            releaseFlags: [
                FeatureFlagsName.enableWalletVisibleViaDeepLink.rawValue: false,
                FeatureFlagsName.enableWalletVisibleIfExists.rawValue: false
            ],
            featureFlags: [:]
        )
        
        XCTAssertEqual(sut.image, .error)
        XCTAssertEqual(sut.title.stringKey, "app_dataDeletionWarningTitle")
        XCTAssertEqual(sut.bodyContent.count, 1)
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_pageWithWallet() {
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: true],
            featureFlags: [:]
        )
        
        XCTAssertEqual(sut.image, .error)
        XCTAssertEqual(sut.title.stringKey, "app_dataDeletionWarningTitle")
        XCTAssertEqual(sut.bodyContent.count, 1)
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_button() {
        XCTAssertEqual(sut.buttonViewModels[0].title.stringKey, "app_signInButton")
        XCTAssertFalse(didCallButtonAction)
        sut.buttonViewModels[0].action()
        XCTAssertTrue(didCallButtonAction)
    }
}
