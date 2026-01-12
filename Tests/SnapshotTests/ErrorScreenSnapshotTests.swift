import Foundation
import GDSCommon
import LocalAuthenticationWrapper
@testable import OneLogin
import Testing

@MainActor
struct ErrorScreenSnapshotTests {
    let analyticsService = MockAnalyticsService()
    
    @Test
    func test_localAuthBiometricsError() {
        let sut = LocalAuthBiometricsErrorViewModel(
            analyticsService: analyticsService,
            localAuthType: .faceID,
            action: {}
        )
        let vc = GDSErrorScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_localAuthSettingsError() {
        let sut = LocalAuthSettingsErrorViewModel(
            analyticsService: analyticsService,
            localAuthType: .faceID
        )
        let vc = GDSErrorScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_appUnavailableError() {
        let sut = AppUnavailableViewModel(analyticsService: analyticsService)
        let vc = GDSCentreAlignedScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_dataDeletedWarning() {
        let sut = DataDeletedWarningViewModel(action: {})
        let vc = GDSErrorScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_genericError() {
        let sut = GenericErrorViewModel(
            analyticsService: analyticsService,
            errorDescription: PersistentSessionError.userRemovedLocalAuth.localizedDescription,
            action: {}
        )
        let vc = GDSErrorScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }

    @Test
    func test_networkConnectionError() {
        let sut = NetworkConnectionErrorViewModel(
            analyticsService: analyticsService,
            action: {}
        )
        let vc = GDSErrorScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_recoverableLoginError() {
        let sut = RecoverableLoginErrorViewModel(
            analyticsService: analyticsService,
            errorDescription: PersistentSessionError.userRemovedLocalAuth.localizedDescription,
            action: {}
        )
        let vc = GDSErrorScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_signOutError() {
        let sut = SignOutErrorViewModel(
            analyticsService: analyticsService,
            error: PersistentSessionError.userRemovedLocalAuth,
            buttonAction: {}
        )
        let vc = GDSErrorScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_signOutWarning() {
        let sut = SignOutWarningViewModel(
            analyticsService: analyticsService,
            action: {}
        )
        let vc = GDSCentreAlignedScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_unrecoverableLoginError() {
        let sut = UnrecoverableLoginErrorViewModel(
            analyticsService: analyticsService,
            errorDescription: PersistentSessionError.userRemovedLocalAuth.localizedDescription
        )
        let vc = GDSErrorScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }
    
    @Test
    func test_updateAppError() {
        let sut = UpdateAppViewModel(analyticsService: analyticsService)
        let vc = GDSCentreAlignedScreen(viewModel: sut)
        
        vc.assertSnapshot()
    }
}
