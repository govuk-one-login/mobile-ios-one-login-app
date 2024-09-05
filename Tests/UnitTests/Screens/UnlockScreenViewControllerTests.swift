@testable import OneLogin
import XCTest

@MainActor
final class UnlockScreenViewControllerTests: XCTestCase {
    var viewModel: UnlockScreenViewModel!
    var sut: UnlockScreenViewController!
    var didPressButton = false
    
    override func setUp() {
        super.setUp()
        
        viewModel = UnlockScreenViewModel(analyticsService: MockAnalyticsService(),
                                          primaryButtonAction: {
            self.didPressButton = true
        })
        sut = UnlockScreenViewController(viewModel: viewModel)
    }
    
    override func tearDown() {
        sut = nil
        viewModel = nil
        
        super.tearDown()
    }
}

extension UnlockScreenViewControllerTests {
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

    func test_loadingLabelContents() throws {
        XCTAssertEqual(try sut.loadingLabel.text, "Loading")
    }

    func test_loadingSpinner() throws {
        XCTAssertEqual(try sut.loadingSpinner.style, .medium)
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
}
