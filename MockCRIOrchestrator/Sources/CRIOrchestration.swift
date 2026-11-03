import UIKit

public enum CardStatus: Sendable {
    case show
    case hide
}

public typealias IDCheckExternalStream = (stream: AsyncStream<CardStatus>, continuation: AsyncStream<CardStatus>.Continuation)

// Matches signatures of public functions of CRIOrchestrator
@MainActor
protocol CRIOrchestration {
    func getIDCheckCard(
        viewController: UIViewController,
        externalStream: IDCheckExternalStream
    ) -> UIViewController
    
    func continueIdentityCheckIfRequired(over viewController: UIViewController)
}
