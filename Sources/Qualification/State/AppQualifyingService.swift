import AppIntegrity
import Foundation
import Logging
import MobilePlatformServices
import Networking
import SecureStore

@MainActor
protocol QualifyingService: AnyObject {
    /// Assign a delegate to receive state updates on:
    /// * ``AppInformationState``
    /// * ``AppSessionState``
    /// * ``RemoteServiceState``
    ///
    /// Assigning a delegate guarantees that any future state updates will be delivered.
    /// Past state updates, including the current state are NOT expected to delivered at the time a delegate is assigned.
    ///
    /// An implementation of ``QualifyingService`` chooses how and when state updates are delivered,
    /// including whether they are delivered as they arrive or scheduled to be delivered (e.g. at the next opportunity)
    ///
    /// - SeeAlso: ``AppQualifyingService``
    /// - Remark: Your implementation of ``QualifyingService`` must provide strong guarantees that state updates
    /// are delivered in the "correct" sequence and represent valid transitions.
    var delegate: AppQualifyingServiceDelegate? { get set }
    
    /// Schedules an evaluation to both the ``AppInformationState`` and ``AppSessionState``.
    /// Assign a ``delegate`` prior to the call to ``initiate()`` to receive state updates as they arrive.
    ///
    /// Once an evaluation is in flight, no further evaluations can be scheduled. In other words, multiple calls
    /// to ``initiate()`` in quick succession are effectively no-op.
    ///
    /// This is by design as it's meant to avoid excessive, unnecessary evaluations that can effectively keep the system
    /// busy and starve it off its ability to execute any other work.
    ///
    /// A state update is guaranteed to be delivered in the correct sequence and represent valid transitions
    /// between states over time. While multiple calls to ``initiate()`` in quick succession do not result in
    /// an equal number of evaluations, you are guaranteed to receive a state update in the correct sequence and represent valid transitions between states over time.
    ///
    func initiate()
    func evaluateUserSession() async
}

@MainActor
protocol AppQualifyingServiceDelegate: AnyObject {
    func didChangeAppInfoState(state appInfoState: AppInformationState)
    func didChangeSessionState(state sessionState: AppSessionState)
    func didChangeServiceState(state: RemoteServiceState)
}

@MainActor
final class AppQualifyingService: QualifyingService {
    private let analyticsService: OneLoginAnalyticsService
    private let updateService: AppInformationProvider
    private let sessionManager: SessionManager
    weak var delegate: AppQualifyingServiceDelegate?
    
    private var initiateTask: Task<Void, Never>?
    
    /// used for testing only
    var _initiateTask: Task<Void, Never>? {
        initiateTask
    }

    private var appInfoState: AppInformationState = .notChecked {
        didSet {
            Task { [appInfoState = appInfoState] in
                delegate?.didChangeAppInfoState(state: appInfoState)
            }
        }
    }
    
    private var sessionState: AppSessionState = .notLoggedIn {
        didSet {
            Task { [sessionState = sessionState] in
                delegate?.didChangeSessionState(state: sessionState)
            }
        }
    }
    
    private var serviceState: RemoteServiceState = .activeService {
        didSet {
            Task { [serviceState = serviceState] in
                delegate?.didChangeServiceState(state: serviceState)
            }
        }
    }
    
    init(
        analyticsService: OneLoginAnalyticsService,
        updateService: AppInformationProvider = AppInformationService(baseURL: AppEnvironment.appInfoURL),
        sessionManager: SessionManager) {
        self.analyticsService = analyticsService
        self.updateService = updateService
        self.sessionManager = sessionManager
        subscribe()
    }
    
    public func initiate() {
        guard initiateTask == nil else {
            return
        }

        self.initiateTask = Task(name: #function) {
            defer {
                self.initiateTask = nil
            }
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
                try await sessionManager.resumeSession()
                sessionState = .loggedIn
            } catch RefreshTokenExchangeError.noInternet {
                appInfoState = .offline
            } catch let error as RefreshTokenExchangeError where error == .appIntegrityFailed {
                analyticsService.logCrash(error)
                
                sessionState = .appIntegrityCheckFailed
            } catch let error as ServerError where error.errorCode == 400 {
                analyticsService.logCrash(error)
                
                return
            } catch let error as SecureStoreError where
                        error.kind == .cantDecryptData {
                analyticsService.logCrash(error)
                
                // This error is treated as recoverable
                // Users' data is not delete but they will need to reauthenticate
                sessionState = .expired
            } catch let error as SecureStoreError {
                analyticsService.logCrash(error)
                
                // All other SecureStoreErrors are treated as recoverable
                // Users' will stay on unlock screen and can attempt local auth again
                sessionState = .localAuthCancelled
            } catch {
                analyticsService.logCrash(error)
                // This will catch PersistentSessionErrors or any uncaught errors from RefreshTokenExchangeManager
                // These errors are treated as unrecoverable
                
                // Users' data is deleted and they will need to log in and readd Wallet credentials
                do {
                    try await sessionManager.clearAllSessionData(presentSystemLogOut: true)
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(accountIntervention),
                                               name: .accountIntervention)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reauthenticationRequired),
                                               name: .reauthenticationRequired)
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

// MARK: - Respond to service events
extension AppQualifyingService {
    @objc private func accountIntervention() {
        serviceState = .accountIntervention
    }
    
    @objc private func reauthenticationRequired() {
        serviceState = .reauthenticationRequired
    }
}
