import Coordination
import GDSCommon
import LocalAuthenticationWrapper
import UIKit

public enum EnrolmentJourney {
    case login
    case wallet
}

final class EnrolmentCoordinator: NSObject,
                                  ChildCoordinator,
                                  NavigationCoordinator {
    let root: UINavigationController
    weak var parentCoordinator: ParentCoordinator?
    private let analyticsService: OneLoginAnalyticsService
    private let sessionManager: SessionManager
    private let localAuthContext: LocalAuthManaging
    private let enrolmentJourney: EnrolmentJourney
    
    private lazy var localAuthManager = OneLoginEnrolmentManager(
        localAuthContext: localAuthContext,
        sessionManager: sessionManager,
        analyticsService: analyticsService,
        coordinator: self
    )
    
    init(
        root: UINavigationController,
        analyticsService: OneLoginAnalyticsService,
        sessionManager: SessionManager,
        localAuthContext: LocalAuthManaging = LocalAuthenticationWrapper(localAuthStrings: .oneLogin),
        enrolmentJourney: EnrolmentJourney = .login
    ) {
        self.root = root
        self.analyticsService = analyticsService
        self.sessionManager = sessionManager
        self.localAuthContext = localAuthContext
        self.enrolmentJourney = enrolmentJourney
    }
    
    func start() {
        do {
            let biometricsType = try localAuthContext.type
            switch biometricsType {
            case .touchID, .faceID:
                let viewModel = BiometricsEnrolmentViewModel(analyticsService: analyticsService,
                                                             biometricsType: biometricsType,
                                                             enrolmentJourney: enrolmentJourney) { [unowned self] in
                    localAuthManager.saveSession()
                } secondaryButtonAction: { [unowned self] in
                    localAuthManager.completeEnrolment()
                }
                let biometricsEnrolmentScreen = GDSInformationViewController(viewModel: viewModel)
                root.pushViewController(biometricsEnrolmentScreen, animated: true)
            case .passcode:
                localAuthManager.saveSession()
            case .none:
                localAuthManager.completeEnrolment()
            }
        } catch {
            preconditionFailure()
        }
    }
}
