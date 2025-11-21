import Foundation

enum RemoteServiceState: Equatable {
    /// The service is active and usable
    case activeService
    /// An intervention is flagged on the user's account
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
