import DesignSystem
@testable import OneLogin
import Testing
import UIKit

@MainActor
struct UnlockScreenViewControllerTests {
    var mockAnalyticsService: MockAnalyticsService!
    var viewModel: UnlockScreenViewModel!
    var sut: UnlockScreenViewController!
        
    init() {
        mockAnalyticsService = MockAnalyticsService()
        viewModel = UnlockScreenViewModel(analyticsService: mockAnalyticsService,
                                          primaryButtonAction: {})
        sut = UnlockScreenViewController(viewModel: viewModel)
    }
}

extension UnlockScreenViewControllerTests {
    @Test
    func test_accessibilityState() {
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        #expect(sut.view.accessibilityViewIsModal)
    }
    
    @Test
    func test_page() throws {
        #expect(try sut.loadingLabel.text == "Loading")
        #expect(try sut.loadingLabel.accessibilityLabel == "Loading GOV.UK One Login")
        #expect(try sut.loadingSpinner.style == .medium)
    }
    
    @Test
    func test_buttonLabelContents() throws {
        #expect(try sut.unlockButton.titleLabel?.adjustsFontForContentSizeCategory ?? false)
        #expect(try sut.unlockButton.titleLabel?.font == UIFont(style: .title3, weight: .bold))
        #expect(try sut.unlockButton.configuration?.title == "Unlock")
        #expect(try sut.unlockButton.titleColor(for: .normal) == DesignSystem.Color.Base.black1)
        #expect(try sut.unlockButton.titleColor(for: .highlighted) == DesignSystem.Color.Base.black1)
        #expect(try sut.unlockButton.configuration?.cornerStyle == .capsule)
    }
    
    @Test
    func test_buttonAction() throws {
        var didPressButton = false
        let viewModel = UnlockScreenViewModel(analyticsService: mockAnalyticsService,
                                              primaryButtonAction: {
            didPressButton = true
        })
        let sut = UnlockScreenViewController(viewModel: viewModel)
        
        #expect(!didPressButton)
        try sut.unlockButton.sendActions(for: .touchUpInside)
        #expect(didPressButton)
    }
}

extension UnlockScreenViewController {
    var unlockButton: UIButton {
        get throws {
            try #require(view[child: "unlock-screen-button"])
        }
    }

    var loadingLabel: UILabel {
        get throws {
            try #require(view[child: "unlock-screen-loading-label"])
        }
    }

    var loadingSpinner: UIActivityIndicatorView {
        get throws {
            try #require(view[child: "unlock-screen-loading-spinner"])
        }
    }
    
    var oneLoginLogo: UIImageView {
        get throws {
            try #require(view[child: "unlock-screen-one-login-logo"])
        }
    }
}
