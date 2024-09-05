import Networking
import SecureStore

protocol QualifyingService {
    var delegate: AppQualifyingServiceDelegate? { get set }
    func initiate()
    func evaluateUser() async
}

enum AppInformationState {
    case appOffline
    case appUnconfirmed
    case appUnavailable
    case appConfirmed
}

enum AppLocalAuthState {
    case userFailed
    case userExpired
    case userUnconfirmed
    case userOneTime
    case userConfirmed
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
            delegate?.didChangeAppInfoState(state: appInfoState)
        }
    }
    
    private var userState: AppLocalAuthState = .userUnconfirmed {
        didSet {
            guard appInfoState == .appConfirmed else {
                // State should not be achieved, delete all session data?
                return
            }
            delegate?.didChangeUserState(state: userState)
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
            do {
                try await qualifyAppVersion()
                await evaluateUser()
            } catch let error as ServerError where 500..<600 ~= error.errorCode {
                appInfoState = .appOffline
            }
        }
    }
    
    private func qualifyAppVersion() async throws {
        let appInfo = try await updateService.fetchAppInfo()
        AppEnvironment.updateReleaseFlags(appInfo.releaseFlags)
        
        guard updateService.currentVersion >= appInfo.minimumVersion else {
            appInfoState = .appUnavailable
            return
        }
        
        appInfoState = .appConfirmed
    }
    
    func evaluateUser() async {
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
                userState = .userFailed
            }
        }
    }
}
