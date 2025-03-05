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
        
        super.tearDown()
    }
}

extension DataDeletedWarningViewModelTests {
    func test_pageNoWallet() {
        
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: false],
            featureFlags: [:]
        )
        
        XCTAssertEqual(sut.image, "exclamationmark.circle")
        XCTAssertEqual(sut.title.stringKey, "app_somethingWentWrongErrorTitle")
        XCTAssertEqual(sut.body, "app_dataDeletionWarningBodyNoWallet")
        XCTAssertNil(sut.secondaryButtonViewModel)
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_pageWithWallet() {
        
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: true],
            featureFlags: [:]
        )
        
        XCTAssertEqual(sut.image, "exclamationmark.circle")
        XCTAssertEqual(sut.title.stringKey, "app_somethingWentWrongErrorTitle")
        XCTAssertEqual(sut.body, "app_dataDeletionWarningBody")
        XCTAssertNil(sut.secondaryButtonViewModel)
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_button() {
        XCTAssertEqual(sut.primaryButtonViewModel.title.stringKey, "app_signInButton")
        XCTAssertFalse(didCallButtonAction)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
    }
}
