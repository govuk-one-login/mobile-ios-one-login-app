@testable import DesignSystem
import GDSAnalytics
@testable import OneLogin
import Testing
import UIKit

@MainActor
struct LocalAuthSettingsErrorViewModelTests {
    let sut: LocalAuthSettingsErrorViewModel
    let mockAnalyticsService = MockAnalyticsService()
    let mockLocalAuthService = MockLocalAuthManager()

    init() {
        sut = LocalAuthSettingsErrorViewModel(analyticsService: mockAnalyticsService,
                                              localAuthType: mockLocalAuthService.type)
    }
}

extension LocalAuthSettingsErrorViewModelTests {
    @Test
    func test_pageVariables() throws {
        let title = sut.body.first as? GDSErrorIconTitleViewModel
        let bodyText = sut.body[1] as? GDSTextViewModel
        let list = sut.body[2] as? GDSListViewModel
        
        #expect(title?.icon == .error)
        #expect(title?.errorTitle.title.stringKey == "app_localAuthManagerErrorTitle")
        #expect(title?.errorTitle.title.value == "Update your phone's security settings")
        #expect(title?.errorTitle.titleFont == .largeTitleBold)
        #expect(title?.errorTitle.alignment == .center)
        #expect(bodyText?.title.stringKey == "app_localAuthManagerErrorBody1")
        #expect(bodyText?.title.value == "To add documents, you need to protect your phone with a passcode.\n\nThis is to make sure no one else can view or add documents to your app.")
        #expect(bodyText?.alignment == .center)
        #expect(list?.title?.stringKey == "app_localAuthManagerErrorBody3")
        #expect(list?.title?.value == "You need to:")
        #expect(list?.titleConfig?.font == .body)
        #expect(list?.titleConfig?.isHeader == true)
        #expect(list?.items.count == 4)
        #expect(list?.items[0].stringKey == "app_localAuthManagerErrorNumberedList0")
        #expect(list?.items[0].value == "Go to your phone settings.")
        #expect(list?.items[1].stringKey == "app_localAuthManagerErrorNumberedList1TouchID")
        #expect(list?.items[1].value == "Tap Touch ID & Passcode.")
        #expect(list?.items[2].stringKey == "app_localAuthManagerErrorNumberedList2")
        #expect(list?.items[2].value == "Tap Turn Passcode On and follow the instructions.")
        #expect(list?.items[3].stringKey == "app_localAuthManagerErrorNumberedList3")
        #expect(list?.items[3].value == "Come back to continue using your documents.")
        #expect(list?.style == .numbered)
        #expect(sut.movableFooter.count == 0)
        #expect(sut.footer.count == 0)
        #expect(sut.rightBarButtonTitle != nil)
        #expect(sut.backButtonTitle == nil)
        #expect(sut.backButtonIsHidden)
    }
    
    @Test
    func test_pageVariables_faceID() throws {
        let sut = LocalAuthSettingsErrorViewModel(analyticsService: mockAnalyticsService,
                                                  localAuthType: .faceID)
        let list = sut.body[2] as? GDSListViewModel
        
        #expect(list?.items[1].stringKey == "app_localAuthManagerErrorNumberedList1FaceID")
        #expect(list?.items[1].value == "Tap Face ID & Passcode.")
    }
    
    @Test
    func test_didAppear_touchID() {
        let vc = GDSScreen(viewModel: sut)
        #expect(mockAnalyticsService.screenViews.count == 0)
        
        vc.viewDidAppear(false)
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.updateTouchID.rawValue,
                                     screen: ErrorAnalyticsScreen.updateTouchID,
                                     titleKey: "app_localAuthManagerErrorTitle")
        
        #expect(mockAnalyticsService.screenViews.count == 1)
        #expect(mockAnalyticsService.screenViews as? [ErrorScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
    
    @Test
    func test_didAppear_faceID() {
        let sut = LocalAuthSettingsErrorViewModel(analyticsService: mockAnalyticsService,
                                                  localAuthType: .faceID)
        let vc = GDSScreen(viewModel: sut)
        #expect(mockAnalyticsService.screenViews.count == 0)
        
        vc.viewDidAppear(false)
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.updateFaceID.rawValue,
                                     screen: ErrorAnalyticsScreen.updateFaceID,
                                     titleKey: "app_localAuthManagerErrorTitle")
        
        #expect(mockAnalyticsService.screenViews.count == 1)
        #expect(mockAnalyticsService.screenViews as? [ErrorScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
    
    @Test
    func test_didDismiss() {
        let vc = GDSScreen(viewModel: sut)
        #expect(mockAnalyticsService.eventsLogged.count == 0)

        vc.viewDidDisappear(false)
        let event = IconEvent(textKey: "back - system")
        
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
    }
}
