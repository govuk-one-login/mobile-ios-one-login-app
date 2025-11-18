import Foundation
import Logging
import MobilePlatformServices
import SecureStore

protocol QualifyingService: AnyObject {
    var delegate: AppQualifyingServiceDelegate? { get set }
    func initiate()
    func evaluateUserSession() async
}

@MainActor
protocol AppQualifyingServiceDelegate: AnyObject {
    func didChangeAppInfoState(state appInfoState: AppInformationState)
    func didChangeSessionState(state sessionState: AppSessionState)
}

final class AppQualifyingService: QualifyingService {
    private let analyticsService: OneLoginAnalyticsService
    private let updateService: AppInformationProvider
    private let sessionManager: SessionManager
    weak var delegate: AppQualifyingServiceDelegate?
    
    private var appInfoState: AppInformationState = .notChecked {
        didSet {
            Task {
                await delegate?.didChangeAppInfoState(state: appInfoState)
            }
        }
    }
    
    private var sessionState: AppSessionState = .notLoggedIn {
        didSet {
            Task {
                await delegate?.didChangeSessionState(state: sessionState)
            }
        }
    }
    
    init(
        analyticsService: OneLoginAnalyticsService,
        updateService: AppInformationProvider = AppInformationService(baseURL: AppEnvironment.appInfoURL),
        sessionManager: SessionManager
    ) {
        self.analyticsService = analyticsService
        self.updateService = updateService
        self.sessionManager = sessionManager
        subscribe()
    }
    
    public func initiate() {
        Task {
            await qualifyAppVersion()
            await evaluateUserSession()
        }
    }
    
    private func qualifyAppVersion() async {
        do {
            let appInfo = try await updateService.fetchAppInfo()
            AppEnvironment.updateFlags(
                releaseFlags: appInfo.releaseFlags,
                featureFlags: appInfo.featureFlags
            )
            
            guard appInfo.allowAppUsage else {
                appInfoState = .unavailable
                return
            }
            
            guard updateService.currentVersion >= appInfo.minimumVersion else {
                appInfoState = .outdated
                return
            }
            
            appInfoState = .qualified
        } catch AppInfoError.invalidResponse {
            appInfoState = .unavailable
        } catch AppInfoError.notConnectedToInternet {
            appInfoState = .offline
        } catch {
            // This would account for all non-successful server responses & any other error
            // To be discussed whether this should route users through the access to the app when offline path
            appInfoState = .error
        }
    }
    
    @MainActor
    func evaluateUserSession() async {
        guard appInfoState == .qualified else {
            // Do not continue with local auth unless app info qualifies
            return
        }
        
        switch sessionManager.sessionState {
        case .expired:
            sessionState = .expired
        case .enrolling, .nonePresent:
            sessionState = .notLoggedIn
        case .oneTime:
            sessionState = .loggedIn
        case .saved:
            do {
                try await sessionManager.resumeSession(tokenExchangeManager: RefreshTokenExchangeManager())
                sessionState = .loggedIn
            } catch SecureStoreError.biometricsCancelled {
                // A SecureStoreError.biometricsCancelled is thrown when the local auth prompt is cancelled/dismissed.
                //
                // In this instance, the user would have the option to retry the local auth prompt
                // As such, no additional action is required.
                sessionState = .localAuthCancelled
            } catch {
                analyticsService.logCrash(error)
                do {
                    try await sessionManager.clearAllSessionData(restartLoginFlow: true)
                } catch {
                    sessionState = .failed(error)
                }
            }
        }
    }
}

// MARK: - Respond to session events
extension AppQualifyingService {
    private func subscribe() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enrolmentComplete),
                                               name: .enrolmentComplete)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionDidExpire),
                                               name: .sessionExpired)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDidLogout),
                                               name: .userDidLogout)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(systemLogUserOut),
                                               name: .systemLogUserOut)
    }

    @objc private func enrolmentComplete() {
        sessionState = .loggedIn
    }
    
    @objc private func sessionDidExpire() {
        sessionState = .expired
    }

    @objc private func userDidLogout() {
        sessionState = .userLogOut
    }
    
    @objc private func systemLogUserOut() {
        sessionState = .systemLogOut
    }
}
