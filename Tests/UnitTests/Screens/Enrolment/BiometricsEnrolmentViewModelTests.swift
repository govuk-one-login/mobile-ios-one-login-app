import GDSAnalytics
import LocalAuthenticationWrapper
@testable import OneLogin
import XCTest

@MainActor
final class BiometricsEnrolmentViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: BiometricsEnrolmentViewModel!
    
    var didCallPrimaryButtonAction = false
    var didCallSecondaryButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = BiometricsEnrolmentViewModel(analyticsService: mockAnalyticsService,
                                           biometricsType: .faceID,
                                           enrolmentJourney: .login) {
            self.didCallPrimaryButtonAction = true
        } secondaryButtonAction: {
            self.didCallSecondaryButtonAction = true
        }
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        
        didCallPrimaryButtonAction = false
        didCallSecondaryButtonAction = false
        
        super.tearDown()
    }
    
    private func makeSut(biometricsType: LocalAuthType = .faceID,
                         enrolmentJourney: EnrolmentJourney = .login) -> BiometricsEnrolmentViewModel {
        let testSut = BiometricsEnrolmentViewModel(analyticsService: mockAnalyticsService,
                                                   biometricsType: biometricsType,
                                                   enrolmentJourney: enrolmentJourney) {
            self.didCallPrimaryButtonAction = true
        } secondaryButtonAction: {
            self.didCallSecondaryButtonAction = true
        }
        return testSut
    }
}

extension BiometricsEnrolmentViewModelTests {
    func test_LoginEnrolment_FaceID_page() {
        sut = makeSut()
        XCTAssertEqual(sut.image, "faceid")
        XCTAssertEqual(sut.biometricsTypeString, "app_FaceID")
        XCTAssertEqual(sut.isFaceID, true)
        XCTAssertEqual(sut.title.stringKey, "app_enableLoginBiometricsTitle")
        XCTAssertEqual(sut.title.value, "Unlock the app with Face ID")
        XCTAssertEqual(sut.body?.stringKey, "app_enableFaceIDBody")
        XCTAssertEqual(sut.body?.variableKeys, ["app_nameString"])
        // swiftlint:disable:next line_length
        XCTAssertEqual(sut.body?.value, "You can use Face ID to unlock the app within 30 minutes of signing in with GOV.UK One Login.\n\nIf you allow Face ID, anyone who can unlock your phone with their face or with your phone\'s passcode will be able to access your app.")
        XCTAssertEqual(sut.primaryButtonViewModel.title.value, "Allow Face ID")
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_LoginEnrolment_TouchID_page() {
        sut = makeSut(biometricsType: .touchID)
        XCTAssertEqual(sut.image, "touchid")
        XCTAssertEqual(sut.biometricsTypeString, "app_TouchID")
        XCTAssertEqual(sut.isFaceID, false)
        XCTAssertEqual(sut.title.stringKey, "app_enableLoginBiometricsTitle")
        XCTAssertEqual(sut.title.value, "Unlock the app with Touch ID")
        XCTAssertEqual(sut.body?.stringKey, "app_enableTouchIDBody")
        XCTAssertEqual(sut.body?.variableKeys, ["app_nameString"])
        // swiftlint:disable:next line_length
        XCTAssertEqual(sut.body?.value, "You can use your fingerprint to unlock the app within 30 minutes of signing in with GOV.UK One Login.\n\nIf you allow Touch ID, anyone who can unlock your phone with their fingerprint or with your phone\'s passcode will be able to access your app.")
        XCTAssertEqual(sut.primaryButtonViewModel.title.value, "Allow Touch ID")
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_WalletEnrolment_FaceID_page() {
        sut = makeSut(enrolmentJourney: .wallet)
        XCTAssertEqual(sut.image, "faceid")
        XCTAssertEqual(sut.biometricsTypeString, "app_FaceID")
        XCTAssertEqual(sut.isFaceID, true)
        XCTAssertEqual(sut.title.stringKey, "app_enableBiometricsTitle")
        XCTAssertEqual(sut.title.value, "Allow Face ID")
        XCTAssertEqual(sut.body?.stringKey, nil)
        XCTAssertEqual(sut.body?.value, nil)
        XCTAssertEqual(sut.primaryButtonViewModel.title.value, "Allow Face ID")
        XCTAssertNotNil(sut.childView)
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_WalletEnrolment_TouchID_page() {
        sut = makeSut(biometricsType: .touchID, enrolmentJourney: .wallet)
        XCTAssertEqual(sut.image, "touchid")
        XCTAssertEqual(sut.biometricsTypeString, "app_TouchID")
        XCTAssertEqual(sut.isFaceID, false)
        XCTAssertEqual(sut.title.stringKey, "app_enableBiometricsTitle")
        XCTAssertEqual(sut.title.value, "Allow Touch ID")
        XCTAssertEqual(sut.body?.stringKey, nil)
        XCTAssertEqual(sut.body?.value, nil)
        XCTAssertEqual(sut.primaryButtonViewModel.title.value, "Allow Touch ID")
        XCTAssertNotNil(sut.childView)
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_primaryButton() {
        sut = makeSut(biometricsType: .faceID, enrolmentJourney: .login)
        XCTAssertFalse(didCallPrimaryButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallPrimaryButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: "allow face id")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
    
    func test_secondaryButton() {
        XCTAssertEqual(sut.secondaryButtonViewModel.title.stringKey, "app_skipButton")
        XCTAssertFalse(didCallSecondaryButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.secondaryButtonViewModel.action()
        XCTAssertTrue(didCallSecondaryButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: "app_skipButton")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
    
    func test_didAppear_faceID() {
        sut = makeSut()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: BiometricEnrolmentAnalyticsScreenID.faceIDEnrolment.rawValue,
                                screen: BiometricEnrolmentAnalyticsScreen.faceIDEnrolment,
                                titleKey: "app_enableLoginBiometricsTitle",
                                variableKeys: ["app_FaceID"])
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
    
    func test_didAppear_faceID_wallet() {
        sut = makeSut(enrolmentJourney: .wallet)
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: BiometricEnrolmentAnalyticsScreenID.faceIDWalletEnrolment.rawValue,
                                screen: BiometricEnrolmentAnalyticsScreen.faceIDEnrolment,
                                titleKey: "app_enableBiometricsTitle",
                                variableKeys: ["app_FaceID"])
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
    
    func test_didAppear_touchID() {
        sut = makeSut(biometricsType: .touchID)
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: BiometricEnrolmentAnalyticsScreenID.touchIDEnrolment.rawValue,
                                screen: BiometricEnrolmentAnalyticsScreen.touchIDEnrolment,
                                titleKey: "app_enableLoginBiometricsTitle",
                                variableKeys: ["app_TouchID"])
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
    
    func test_didAppear_touchID_wallet() {
        sut = makeSut(biometricsType: .touchID, enrolmentJourney: .wallet)
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: BiometricEnrolmentAnalyticsScreenID.touchIDWalletEnrolment.rawValue,
                                screen: BiometricEnrolmentAnalyticsScreen.touchIDEnrolment,
                                titleKey: "app_enableBiometricsTitle",
                                variableKeys: ["app_TouchID"])
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
}
