protocol QualifyingService {
    var delegate: AppQualifyingServiceDelegate? { get set }
    func qualifyAppVersion() async throws
}

enum AppInformationState {
    case offline
    case unconfirmed
    case unavailable
    case onlineConfirmed(app: App)
}

final class AppQualifyingService: QualifyingService {
    private let updateService: AppInformationServicing
    weak var delegate: AppQualifyingServiceDelegate?
    
    private var state: AppInformationState = .unconfirmed {
        didSet {
            delegate?.didChangeState(state: state)
        }
    }
    
    init(updateService: AppInformationServicing = AppInformationService()) {
        self.updateService = updateService
        initiate()
    }
    
    func initiate() {
        Task {
            do {
                try await qualifyAppVersion()
            } catch {
                state = .offline
            }
        }
    }
    
    func qualifyAppVersion() async throws {
        let appInfo = try await updateService.fetchAppInfo()
        AppEnvironment.updateReleaseFlags(appInfo.releaseFlags)
        
        guard updateService.currentVersion >= appInfo.minimumVersion else {
            state = .unavailable
            return
        }
        
        state = .onlineConfirmed(app: appInfo)
    }
}
