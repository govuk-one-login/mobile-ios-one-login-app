import Networking
import SecureStore

protocol QualifyingService {
    var delegate: AppQualifyingServiceDelegate? { get set }
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
    case userConfirmed
}

final class AppQualifyingService: QualifyingService {
    private let updateService: AppInformationServicing
    private let sessionManager: SessionManager
    weak var delegate: AppQualifyingServiceDelegate?
    
    private var appState: AppInformationState = .appUnconfirmed {
        didSet {
            if appState == .appOffline {
                // Query cache?
            }
            delegate?.didChangeAppInfoState(state: appState)
        }
    }
    
    private var userState: AppLocalAuthState = .userUnconfirmed {
        didSet {
            guard appState == .appConfirmed else {
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
    
    private func initiate() {
        Task {
            do {
                try await qualifyAppVersion()
                await evaluateUser()
            } catch let error as ServerError where 500..<600 ~= error.errorCode {
                appState = .appOffline
            }
        }
    }
    
    private func qualifyAppVersion() async throws {
        let appInfo = try await updateService.fetchAppInfo()
        AppEnvironment.updateReleaseFlags(appInfo.releaseFlags)
        
        guard updateService.currentVersion >= appInfo.minimumVersion else {
            appState = .appUnavailable
            return
        }
        
        appState = .appConfirmed
    }
    
    func evaluateUser() async {
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
