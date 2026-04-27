import AppIntegrity
import Foundation
import Logging
import MobilePlatformServices
import Networking
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
    func didChangeServiceState(state: RemoteServiceState)
}

final class AppQualifyingService: QualifyingService {
    private let analyticsService: OneLoginAnalyticsService
    private let updateService: AppInformationProvider
    private let sessionManager: SessionManager
    private let appIntegrityProvider: () throws -> AppIntegrityProvider
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
    
    private var serviceState: RemoteServiceState = .activeService {
        didSet {
            Task {
                await delegate?.didChangeServiceState(state: serviceState)
            }
        }
    }
    
    convenience init(
        analyticsService: OneLoginAnalyticsService,
        updateService: AppInformationProvider = AppInformationService(baseURL: AppEnvironment.appInfoURL),
        sessionManager: SessionManager
    ) {
        self.init(analyticsService: analyticsService,
                  updateService: updateService,
                  sessionManager: sessionManager,
                  appIntegrityProvider: try FirebaseAppIntegrityService.firebaseAppCheck())
    }

    init(
        analyticsService: OneLoginAnalyticsService,
        updateService: AppInformationProvider = AppInformationService(baseURL: AppEnvironment.appInfoURL),
        sessionManager: SessionManager,
        appIntegrityProvider: @autoclosure @escaping () throws(AppIntegritySigningError) -> AppIntegrityProvider) {
        self.analyticsService = analyticsService
        self.updateService = updateService
        self.sessionManager = sessionManager
        self.appIntegrityProvider = appIntegrityProvider
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
                try await sessionManager.resumeSession(
                    tokenExchangeManager: RefreshTokenExchangeManager(),
                    appIntegrityProvider: try appIntegrityProvider()
                )
                sessionState = .loggedIn
            } catch RefreshTokenExchangeError.noInternet {
                appInfoState = .offline
            } catch let error as RefreshTokenExchangeError where error == .appIntegrityFailed {
                analyticsService.logCrash(error)
                
                sessionState = .appIntegrityCheckFailed
            } catch let error as ServerError where error.errorCode == 400 {
                analyticsService.logCrash(error)
                
                return
            } catch let error as SecureStoreErrorV2 where
                        error.kind == .cantDecryptData {
                analyticsService.logCrash(error)
                
                // This error is treated as recoverable
                // Users' data is not delete but they will need to reauthenticate
                sessionState = .expired
            } catch let error as SecureStoreErrorV2 {
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
