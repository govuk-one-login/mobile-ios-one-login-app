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
        XCTAssertEqual(sut.title.value.getEnglishString(), "Unlock the app with Face ID")
        XCTAssertEqual(sut.title.stringKey, "app_enableLoginBiometricsTitle")
        XCTAssertEqual(sut.body?.stringKey, "app_enableFaceIDBody")
        XCTAssertEqual(sut.primaryButtonViewModel.title.value.getEnglishString(), "Allow Face ID")
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_LoginEnrolment_TouchID_page() {
        sut = makeSut(biometricsType: .touchID)
        XCTAssertEqual(sut.image, "touchid")
        XCTAssertEqual(sut.biometricsTypeString, "app_TouchID")
        XCTAssertEqual(sut.isFaceID, false)
        XCTAssertEqual(sut.title.value.getEnglishString(), "Unlock the app with Touch ID")
        XCTAssertEqual(sut.title.stringKey, "app_enableLoginBiometricsTitle")
        XCTAssertEqual(sut.body?.stringKey, "app_enableTouchIDBody")
        XCTAssertEqual(sut.primaryButtonViewModel.title.value.getEnglishString(), "Allow Touch ID")
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_WalletEnrolment_FaceID_page() {
        sut = makeSut(enrolmentJourney: .wallet)
        XCTAssertEqual(sut.image, "faceid")
        XCTAssertEqual(sut.biometricsTypeString, "app_FaceID")
        XCTAssertEqual(sut.isFaceID, true)
        XCTAssertEqual(sut.title.value.getEnglishString(), "Allow Face ID")
        XCTAssertEqual(sut.title.stringKey, "app_enableBiometricsTitle")
        XCTAssertEqual(sut.body?.stringKey, nil)
        XCTAssertEqual(sut.primaryButtonViewModel.title.value.getEnglishString(), "Allow Face ID")
        XCTAssertNotNil(sut.childView)
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_WalletEnrolment_TouchID_page() {
        sut = makeSut(biometricsType: .touchID, enrolmentJourney: .wallet)
        XCTAssertEqual(sut.image, "touchid")
        XCTAssertEqual(sut.biometricsTypeString, "app_TouchID")
        XCTAssertEqual(sut.isFaceID, false)
        XCTAssertEqual(sut.title.value.getEnglishString(), "Allow Touch ID")
        XCTAssertEqual(sut.title.stringKey, "app_enableBiometricsTitle")
        XCTAssertEqual(sut.body?.stringKey, nil)
        XCTAssertEqual(sut.primaryButtonViewModel.title.value.getEnglishString(), "Allow Touch ID")
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
}
