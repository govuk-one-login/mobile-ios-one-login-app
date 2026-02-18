import Foundation

enum RemoteServiceState: Equatable {
    /// The service is active and usable
    case activeService
    /// An intervention is flagged on the user's account
    case accountIntervention
    /// User needs to reauthenticate
    case reauthenticationRequired

    static func == (lhs: RemoteServiceState, rhs: RemoteServiceState) -> Bool {
        switch (lhs, rhs) {
        case (.activeService, .activeService),
            (.accountIntervention, .accountIntervention),
            (.reauthenticationRequired, .reauthenticationRequired):
            true
        default:
            false
        }
    }
}
