import Coordination
import GDSCommon
import LocalAuthenticationWrapper
import UIKit

final class EnrolmentCoordinator: NSObject,
                                  ChildCoordinator,
                                  NavigationCoordinator {
    let root: UINavigationController
    weak var parentCoordinator: ParentCoordinator?
    private let analyticsService: OneLoginAnalyticsService
    private let sessionManager: SessionManager
    private let localAuthContext: LocalAuthWrap
    
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
        localAuthContext: LocalAuthWrap = LocalAuthenticationWrapper(localAuthStrings: .oneLogin)
    ) {
        self.root = root
        self.analyticsService = analyticsService
        self.sessionManager = sessionManager
        self.localAuthContext = localAuthContext
    }
    
    func start() {
        do {
            switch try localAuthContext.type {
            case .touchID:
                let viewModel = TouchIDEnrolmentViewModel(analyticsService: analyticsService) { [unowned self] in
                    localAuthManager.saveSession()
                } secondaryButtonAction: { [unowned self] in
                    localAuthManager.completeEnrolment()
                }
                let touchIDEnrolmentScreen = GDSInformationViewController(viewModel: viewModel)
                root.pushViewController(touchIDEnrolmentScreen, animated: true)
            case .faceID:
                let viewModel = FaceIDEnrolmentViewModel(analyticsService: analyticsService) { [unowned self] in
                    localAuthManager.saveSession()
                } secondaryButtonAction: { [unowned self] in
                    localAuthManager.completeEnrolment()
                }
                let faceIDEnrolmentScreen = GDSInformationViewController(viewModel: viewModel)
                root.pushViewController(faceIDEnrolmentScreen, animated: true)
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
