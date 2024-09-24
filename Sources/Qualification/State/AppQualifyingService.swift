import Foundation
import Logging
import MobilePlatformServices
import Networking
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
    private let analyticsService: AnalyticsService
    private let updateService: AppInformationProvider
    private let sessionManager: SessionManager
    weak var delegate: AppQualifyingServiceDelegate?
    
    private var appInfoState: AppInformationState = .appUnconfirmed {
        didSet {
            if appInfoState == .appOffline {
                // Query cache?
            }
            Task {
                await delegate?.didChangeAppInfoState(state: appInfoState)
            }
        }
    }
    
    private var userState: AppLocalAuthState = .userUnconfirmed {
        didSet {
            Task {
                await delegate?.didChangeUserState(state: userState)
            }
        }
    }
    
    init(analyticsService: AnalyticsService,
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
            AppEnvironment.updateReleaseFlags(appInfo.releaseFlags)
            
            guard updateService.currentVersion >= appInfo.minimumVersion else {
                appInfoState = .appOutdated
                return
            }
            
            appInfoState = .appConfirmed
        } catch URLError.notConnectedToInternet {
            appInfoState = .appOffline
        } catch {
            // This would account for all non-successful server responses & any other error
            // To be discussed whether this should route users through the access to the app when offline path
            appInfoState = .appInfoError
        }
    }
    
    func evaluateUser() async {
        guard appInfoState == .appConfirmed else {
            // Do not continue with local auth unless app info qualifies
            return
        }
        
        if sessionManager.isOneTimeUser {
            userState = .userConfirmed
        } else {
            guard sessionManager.expiryDate != nil else {
                userState = .userUnconfirmed
                return
            }
            
            guard sessionManager.isSessionValid else {
                userState = .userExpired
                return
            }
            
            do {
                try await MainActor.run {
                    try sessionManager.resumeSession()
                    userState = .userConfirmed
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
                    sessionManager.endCurrentSession()
                } catch {
                    userState = .userFailed(error)
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
        userState = .userConfirmed
    }

    @objc private func sessionDidExpire() {
        userState = .userExpired
    }

    @objc private func userDidLogout() {
        userState = .userUnconfirmed
    }
}
