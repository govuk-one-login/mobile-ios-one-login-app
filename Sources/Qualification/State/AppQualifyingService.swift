import Foundation
import Logging
import MobilePlatformServices
import SecureStore

protocol QualifyingService: AnyObject {
    var delegate: AppQualifyingServiceDelegate? { get set }
    func evaluateUser() async
}

@MainActor
protocol AppQualifyingServiceDelegate: AnyObject {
    func didChangeAppInfoState(state appInfoState: AppInformationState)
    func didChangeUserState(state userState: AppLocalAuthState)
}

final class AppQualifyingService: QualifyingService {
    private let analyticsService: OneLoginAnalyticsService
    private let updateService: AppInformationProvider
    private let sessionManager: SessionManager
    weak var delegate: AppQualifyingServiceDelegate?
    
    private var appInfoState: AppInformationState = .notChecked {
        didSet {
            if appInfoState == .offline {
                // Query cache?
            }
            Task {
                await delegate?.didChangeAppInfoState(state: appInfoState)
            }
        }
    }
    
    private var userState: AppLocalAuthState = .notLoggedIn {
        didSet {
            Task {
                await delegate?.didChangeUserState(state: userState)
            }
        }
    }
    
    init(analyticsService: OneLoginAnalyticsService,
         updateService: AppInformationProvider = AppInformationService(baseURL: AppEnvironment.appInfoURL),
         sessionManager: SessionManager) {
        self.analyticsService = analyticsService
        self.updateService = updateService
        self.sessionManager = sessionManager
        subscribe()
    }
    
    func initiate() {
        Task {
            await qualifyAppVersion()
            await evaluateUser()
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
        } catch URLError.notConnectedToInternet {
            appInfoState = .offline
        } catch {
            // This would account for all non-successful server responses & any other error
            // To be discussed whether this should route users through the access to the app when offline path
            appInfoState = .error
        }
    }
    
    func evaluateUser() async {
        guard appInfoState == .qualified else {
            // Do not continue with local auth unless app info qualifies
            return
        }
        
        if sessionManager.isOneTimeUser {
            userState = .loggedIn
        } else {
            guard sessionManager.expiryDate != nil else {
                userState = .notLoggedIn
                return
            }
            
            guard sessionManager.isSessionValid else {
                userState = .expired
                return
            }
            
            do {
                try await MainActor.run {
                    try sessionManager.resumeSession()
                    userState = .loggedIn
                }
            } catch SecureStoreError.cantDecryptData {
                // A SecureStoreError.cantDecryptData is thrown when the local auth prompt is cancelled/dismissed.
                // We should look at renaming this error case within the secure store package.
                //
                // In this instance, the user would have the option to retry the local auth prompt
                // As such, no additional action is required.
                return
            } catch {
                do {
                    analyticsService.logCrash(error)
                    try sessionManager.clearAllSessionData()
                } catch {
                    userState = .failed(error)
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
                                               name: .didLogout)
    }

    @objc private func enrolmentComplete() {
        userState = .loggedIn
    }

    @objc private func sessionDidExpire() {
        userState = .expired
    }

    @objc private func userDidLogout() {
        userState = .notLoggedIn
    }
}
