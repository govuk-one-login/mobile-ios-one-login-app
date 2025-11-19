import Foundation

enum RemoteServiceState: Equatable {
    case activeService
    /// An error occurred in local authentication
    case accountIntervention

    static func == (lhs: RemoteServiceState, rhs: RemoteServiceState) -> Bool {
        switch (lhs, rhs) {
        case (.activeService, .activeService),
            (.accountIntervention, .accountIntervention):
            true
        default:
            false
        }
    }
}
