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
    func test_pageNoWallet() throws {
        AppEnvironment.updateFlags(
            releaseFlags: [
                FeatureFlagsName.enableWalletVisibleToAll.rawValue: false,
                FeatureFlagsName.enableWalletVisibleIfExists.rawValue: false
            ],
            featureFlags: [:]
        )
        
        XCTAssertEqual(sut.image, .error)
        XCTAssertEqual(sut.title.stringKey, "app_dataDeletionWarningTitle")
        XCTAssertEqual(sut.title.value, "Something went wrong")
        let bodyLabel = try XCTUnwrap(sut.bodyContent.first?.uiView as? UILabel)
        XCTAssertEqual(sut.bodyContent.count, 1)
        // swiftlint:disable:next line_length
        XCTAssertEqual(bodyLabel.text, "We could not confirm your sign in details.\n\nTo keep your information secure, your preference for using Touch ID or Face ID to unlock the app has been reset.\n\nYou need to sign in and set your preferences again to continue using the app.")
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_pageWithWallet() throws {
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: true],
            featureFlags: [:]
        )
        
        XCTAssertEqual(sut.image, .error)
        XCTAssertEqual(sut.title.stringKey, "app_dataDeletionWarningTitle")
        XCTAssertEqual(sut.title.value, "Something went wrong")
        XCTAssertEqual(sut.bodyContent.count, 1)
        let bodyLabel = try XCTUnwrap(sut.bodyContent.first?.uiView as? UILabel)
        // swiftlint:disable:next line_length
        XCTAssertEqual(bodyLabel.text, "We could not confirm your sign in details.\n\nTo keep your information secure, any documents in your GOV.UK Wallet have been removed and your app preferences have been reset.\n\nYou need to sign in again and set your preferences again to continue using the app. You’ll then be able to add documents to you GOV.UK Wallet.")
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
