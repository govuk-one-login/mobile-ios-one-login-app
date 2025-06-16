import Coordination
import GDSCommon
import LocalAuthenticationWrapper
import UIKit
import Wallet

final class LocalAuthServiceWallet: WalletLocalAuthService {
    let localAuthentication: LocalAuthManaging
    private var analyticsService: OneLoginAnalyticsService
    private let sessionManager: SessionManager
    private let walletCoodinator: WalletCoordinator
    private var isPasscodeEnrolled = false
    var biometricsEnrolmentScreen: GDSInformationViewController?
    
    private lazy var localAuthManager = OneLoginEnrolmentManager(
        localAuthContext: localAuthentication,
        sessionManager: sessionManager,
        analyticsService: analyticsService,
        coordinator: walletCoodinator
    )
    
    init(walletCoordinator: WalletCoordinator,
         analyticsService: OneLoginAnalyticsService,
         sessionManager: SessionManager,
         localAuthentication: LocalAuthManaging = LocalAuthenticationWrapper(localAuthStrings: .oneLogin)) {
        self.analyticsService = analyticsService
        self.sessionManager = sessionManager
        self.localAuthentication = localAuthentication
        self.walletCoodinator = walletCoordinator
    }
    
    func enrolLocalAuth(_ minimum: any WalletLocalAuthType, completion: @escaping () -> Void) {
        do {
            let biometricsType = try localAuthentication.type
            switch biometricsType {
            case .touchID, .faceID:
                let viewModel = BiometricsEnrolmentViewModel(analyticsService: analyticsService,
                                                             biometricsType: biometricsType,
                                                             enrolmentJourney: .wallet) { [unowned self] in
                    localAuthManager.saveSession(isWalletEnrolment: true) { [unowned self] in
                        self.biometricsEnrolmentScreen?.dismiss(animated: true)
                        completion()
                    }
                } secondaryButtonAction: { [unowned self] in
                    localAuthManager.completeEnrolment(isWalletEnrolment: true) { [unowned self] in
                        self.biometricsEnrolmentScreen?.dismiss(animated: true)
                        completion()
                    }
                }
                biometricsEnrolmentScreen = GDSInformationViewController(viewModel: viewModel)
                walletCoodinator.root.modalPresentationStyle = .pageSheet
                walletCoodinator.root.present(biometricsEnrolmentScreen ?? GDSInformationViewController(viewModel: viewModel), animated: true)
            case .passcode:
                localAuthManager.saveSession(isWalletEnrolment: true) { [unowned self] in
                    self.isPasscodeEnrolled = true
                    completion()
                }
            case .none:
                localAuthManager.completeEnrolment(isWalletEnrolment: true) {
                    completion()
                }
            }
        } catch {
            preconditionFailure()
        }
    }
    
    func isEnrolled(_ minimum: any WalletLocalAuthType) -> Bool {
        return localAuthentication.isEnrolled() || isPasscodeEnrolled
    }
    
    func userCancelled() {
        biometricsEnrolmentScreen?.dismiss(animated: true)
        WalletSDK.walletTabSelected()
    }
}
