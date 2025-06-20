import Coordination
import GDSCommon
import LocalAuthenticationWrapper
import UIKit
import Wallet
import WalletInterface

final class LocalAuthServiceWallet: WalletLocalAuthService {
    let localAuthentication: LocalAuthManaging
    private var analyticsService: OneLoginAnalyticsService
    private let sessionManager: SessionManager
    private let walletCoodinator: WalletCoordinator
    var biometricsNavigationController = UINavigationController()
    
    private var localAuthManager: EnrolmentManager
    
    init(
        walletCoordinator: WalletCoordinator,
        analyticsService: OneLoginAnalyticsService,
        sessionManager: SessionManager,
        localAuthentication: LocalAuthManaging = LocalAuthenticationWrapper(
            localAuthStrings: .oneLogin
        ),
        enrolmentManager: EnrolmentManager.Type = OneLoginEnrolmentManager.self
    ) {
        self.analyticsService = analyticsService
        self.sessionManager = sessionManager
        self.localAuthentication = localAuthentication
        self.walletCoodinator = walletCoordinator
        self.localAuthManager = enrolmentManager.init(
            localAuthContext: localAuthentication,
            sessionManager: sessionManager,
            analyticsService: analyticsService,
            coordinator: walletCoordinator
        )
    }
    
    func enrolLocalAuth(_ minimum: any WalletLocalAuthType, completion: @escaping () -> Void) {
        do {
            self.biometricsNavigationController = UINavigationController()
            let biometricsType = try localAuthentication.type
            switch biometricsType {
            case .touchID, .faceID:
                let viewModel = BiometricsEnrolmentViewModel(analyticsService: analyticsService,
                                                             biometricsType: biometricsType,
                                                             enrolmentJourney: .wallet) { [unowned self] in
                    acceptedBiometrics(completion: completion)
                } secondaryButtonAction: { [unowned self] in
                    let viewModel = LocalAuthBiometricsErrorViewModel(analyticsService: analyticsService, localAuthType: biometricsType) { [unowned self] in
                        acceptedBiometrics(completion: completion)
                    } dismissAction: {
                        completion()
                    }
                    let skippedBiometricsViewController =  GDSErrorScreen(viewModel: viewModel)
                    biometricsNavigationController.pushViewController(skippedBiometricsViewController, animated: true)
                }
                let biometricsEnrolmentScreen = GDSInformationViewController(viewModel: viewModel)
                
                biometricsNavigationController.setViewControllers([biometricsEnrolmentScreen], animated: false)
                biometricsNavigationController.modalPresentationStyle = .pageSheet
                biometricsNavigationController.presentationController?.delegate = walletCoodinator
                walletCoodinator.root.present(biometricsNavigationController,
                                              animated: true)
            case .passcode:
                localAuthManager.saveSession(isWalletEnrolment: true) {
                    completion()
                }
            case .none:
                let viewModel = LocalAuthSettingsErrorViewModel(analyticsService: analyticsService, localAuthType: try localAuthentication.deviceBiometricsType) { [unowned self] in
                    biometricsNavigationController.dismiss(animated: true)
                    completion()
                }
                let settingsErrorScreen = GDSErrorScreen(viewModel: viewModel)
                
                biometricsNavigationController.setViewControllers([settingsErrorScreen], animated: false)
                biometricsNavigationController.modalPresentationStyle = .pageSheet
                biometricsNavigationController.presentationController?.delegate = walletCoodinator
                walletCoodinator.root.present(biometricsNavigationController,
                                              animated: true)
            }
        } catch {
            preconditionFailure()
        }
    }
    
    func isEnrolled(_ minimum: any WalletLocalAuthType) -> Bool {
        guard let minimumAuth = minimum as? LocalAuth else {
            return false
        }
        
        do {
            let type = try localAuthentication.type
            switch minimumAuth {
            case .biometrics:
                return (type == .touchID || type == .faceID) && localAuthentication.hasBeenPrompted()
            default:
                return (type == .touchID || type == .faceID || type == .passcode) && localAuthentication.hasBeenPrompted()
            }
        } catch {
            preconditionFailure()
        }
    }
    
    func userCancelled() {
        WalletSDK.walletTabSelected()
        biometricsNavigationController.dismiss(animated: true)
    }
    
    private func acceptedBiometrics(completion: @escaping () -> Void) {
        localAuthManager.saveSession(isWalletEnrolment: true) { [unowned self] in
            biometricsNavigationController.dismiss(animated: true)
            completion()
        }
    }
}
