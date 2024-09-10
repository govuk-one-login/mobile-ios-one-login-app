import Foundation
import Networking
import SecureStore

protocol QualifyingService: AnyObject {
    var delegate: AppQualifyingServiceDelegate? { get set }
    func initiate()
    func evaluateUser() async
}

enum AppInformationState {
    case appOffline
    case appInfoError
    case appOutdated
    case appUnconfirmed
    case appConfirmed
    // TODO: DCMAW-9824 - New state may be needed for appInfo.allowAppUsage which corresponds to 'available' in appInfo json
}

enum AppLocalAuthState: Equatable {
    case userFailed(_ error: Error)
    case userExpired
    case userUnconfirmed
    case userOneTime
    case userConfirmed
    
    static func == (lhs: AppLocalAuthState, rhs: AppLocalAuthState) -> Bool {
        switch (lhs, rhs) {
        case (.userFailed, .userFailed),
            (.userExpired, .userExpired),
            (.userUnconfirmed, .userUnconfirmed),
            (.userOneTime, .userOneTime),
            (.userConfirmed, .userConfirmed):
            return true
        default:
            return false
        }
    }
}

final class AppQualifyingService: QualifyingService {
    private let updateService: AppInformationServicing
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
    
    init(updateService: AppInformationServicing = AppInformationService(),
         sessionManager: SessionManager) {
        self.updateService = updateService
        self.sessionManager = sessionManager
        initiate()
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
            userState = .userOneTime
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
            } catch {
                sessionManager.endCurrentSession()
                sessionManager.clearAllSessionData()
                userState = .userFailed(error)
            }
        }
    }
}
