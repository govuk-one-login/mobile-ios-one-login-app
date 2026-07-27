import DesignSystem
import Foundation
import LocalAuthenticationWrapper
@testable import OneLogin
@testable import SnapshotHelpers
import Testing
import UIKit

@MainActor
struct ErrorScreenSnapshotTests {
    let analyticsService = MockAnalyticsService()
    
    @Test
    func test_localAuthBiometricsErrorFaceId() {
        let root = UINavigationController()
        let sut = LocalAuthBiometricsErrorViewModel(
            analyticsService: analyticsService,
            localAuthType: .faceID,
            action: {}
        )
        let vc = GDSScreen(viewModel: sut)
        
        root.pushViewController(vc, animated: false)
        root.assertSnapshot()
    }
    
    @Test
    func test_localAuthBiometricsErrorTouchId() {
        let root = UINavigationController()
        let sut = LocalAuthBiometricsErrorViewModel(
            analyticsService: analyticsService,
            localAuthType: .touchID,
            action: {}
        )
        let vc = GDSScreen(viewModel: sut)
        
        root.pushViewController(vc, animated: false)
        root.assertSnapshot()
    }
    
    @Test
    func test_localAuthSettingsErrorFaceId() {
        let root = UINavigationController()
        let sut = LocalAuthSettingsErrorViewModel(
            analyticsService: analyticsService,
            localAuthType: .faceID
        )
        let vc = GDSScreen(viewModel: sut)
        
        root.pushViewController(vc, animated: false)
        root.assertSnapshot()
    }
    
    @Test
    func test_localAuthSettingsErrorTouchId() {
        let root = UINavigationController()
        let sut = LocalAuthSettingsErrorViewModel(
            analyticsService: analyticsService,
            localAuthType: .touchID
        )
        let vc = GDSScreen(viewModel: sut)
        
        root.pushViewController(vc, animated: false)
        root.assertSnapshot()
    }
    
    @Test
    func test_appIntegrityError() {
        let root = UINavigationController()
        let sut = AppIntegrityErrorViewModel(analyticsService: analyticsService)
        let vc = GDSScreen(viewModel: sut)
        
        root.pushViewController(vc, animated: false)
        root.assertSnapshot()
    }
    
    @Test
    func test_appUnavailableError() {
        let root = UINavigationController()
        let sut = AppUnavailableViewModel(analyticsService: analyticsService)
        let vc = GDSScreen(viewModel: sut)
        
        root.pushViewController(vc, animated: false)
        root.assertSnapshot()
    }
    
    @Test
    func test_dataDeletedWarning() {
        let root = UINavigationController()
        let sut = DataDeletedWarningViewModel(action: {})
        let vc = GDSScreen(viewModel: sut)
        
        root.pushViewController(vc, animated: false)
        root.assertSnapshot()
    }
    
    @Test
    func test_genericError() {
        let root = UINavigationController()
        let sut = GenericErrorViewModel(
            analyticsService: analyticsService,
            errorDescription: PersistentSessionError(.userRemovedLocalAuth).localizedDescription,
            action: {}
        )
        let vc = GDSScreen(viewModel: sut)
        
        root.pushViewController(vc, animated: false)
        root.assertSnapshot()
    }

    @Test
    func test_networkConnectionError() {
        let root = UINavigationController()
        let sut = NetworkConnectionErrorViewModel(
            analyticsService: analyticsService,
            action: {}
        )
        let vc = GDSScreen(viewModel: sut)
        
        root.pushViewController(vc, animated: false)
        root.assertSnapshot()
    }
    
    @Test
    func test_recoverableLoginError() {
        let root = UINavigationController()
        let sut = RecoverableLoginErrorViewModel(
            analyticsService: analyticsService,
            errorDescription: PersistentSessionError(.userRemovedLocalAuth).localizedDescription,
            action: {}
        )
        let vc = GDSScreen(viewModel: sut)
        
        root.pushViewController(vc, animated: false)
        root.assertSnapshot()
    }
    
    @Test
    func test_signOutError() {
        let root = UINavigationController()
        let sut = SignOutErrorViewModel(
            analyticsService: analyticsService,
            error: PersistentSessionError(.userRemovedLocalAuth),
            action: {}
        )
        let vc = GDSScreen(viewModel: sut)
        
        root.pushViewController(vc, animated: false)
        root.assertSnapshot()
    }
    
    @Test
    func test_unrecoverableLoginError() {
        let root = UINavigationController()
        let sut = UnrecoverableLoginErrorViewModel(
            analyticsService: analyticsService,
            errorDescription: PersistentSessionError(.userRemovedLocalAuth).localizedDescription
        )
        let vc = GDSScreen(viewModel: sut)
        
        root.pushViewController(vc, animated: false)
        root.assertSnapshot()
    }
    
    @Test
    func test_updateAppError() {
        let root = UINavigationController()
        let sut = UpdateAppViewModel(analyticsService: analyticsService)
        let vc = GDSScreen(viewModel: sut)
        
        root.pushViewController(vc, animated: false)
        root.assertSnapshot()
    }
}
