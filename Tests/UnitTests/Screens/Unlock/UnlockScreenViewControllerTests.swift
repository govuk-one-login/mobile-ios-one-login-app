@testable import OneLogin
import XCTest

@MainActor
final class UnlockScreenViewControllerTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var viewModel: UnlockScreenViewModel!
    var sut: UnlockScreenViewController!
    
    var didPressButton = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        viewModel = UnlockScreenViewModel(analyticsService: mockAnalyticsService,
                                          primaryButtonAction: {
            self.didPressButton = true
        })
        sut = UnlockScreenViewController(viewModel: viewModel)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        viewModel = nil
        sut = nil
        
        didPressButton = false
        
        super.tearDown()
    }
}

extension UnlockScreenViewControllerTests {
    func test_accessibilityState() {
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        XCTAssertTrue(sut.view.accessibilityViewIsModal)
    }
    
    func test_page() throws {
        XCTAssertEqual(try sut.loadingLabel.text, "Loading")
        XCTAssertEqual(try sut.loadingSpinner.style, .medium)
    }
    
    func test_ButtonLabelContents() throws {
        XCTAssertEqual(try sut.unlockButton.titleLabel?.adjustsFontForContentSizeCategory, true)
        XCTAssertEqual(try sut.unlockButton.titleLabel?.font, UIFont(style: .title3, weight: .bold))
        XCTAssertEqual(try sut.unlockButton.title(for: .normal), "Unlock")
    }
    
    func test_buttonAction() throws {
        XCTAssertFalse(didPressButton)
        try sut.unlockButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didPressButton)
    }
    
    func test_logo() {
        XCTAssertTrue(try sut.oneLoginLogo.isAccessibilityElement)
        XCTAssertEqual(try sut.oneLoginLogo.accessibilityHint, "GOV.UK One Login logo")
    }
}

extension UnlockScreenViewController {
    var unlockButton: UIButton {
        get throws {
            try XCTUnwrap(view[child: "unlock-screen-button"])
        }
    }

    var loadingLabel: UILabel {
        get throws {
            try XCTUnwrap(view[child: "unlock-screen-loading-label"])
        }
    }

    var loadingSpinner: UIActivityIndicatorView {
        get throws {
            try XCTUnwrap(view[child: "unlock-screen-loading-spinner"])
        }
    }
    
    var oneLoginLogo: UIImageView {
        get throws {
            try XCTUnwrap(view[child: "unlock-screen-one-login-logo"])
        }
    }
}
