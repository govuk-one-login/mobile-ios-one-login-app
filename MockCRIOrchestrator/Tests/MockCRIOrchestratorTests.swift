import CRIOrchestrator
@testable import MockCRIOrchestrator
import Testing
import UIKit

extension MockCRIOrchestrator {
    static func make(
        idCheckJourney: Bool = false,
        streamContinuation: AsyncStream<CardStatus>.Continuation? = nil,
        hostingViewController: UIViewController = UIViewController()
    ) -> MockCRIOrchestrator {
        return MockCRIOrchestrator(
            idCheckJourney: idCheckJourney,
            streamContinuation: streamContinuation,
            hostingViewController: hostingViewController
        )
    }
}

@MainActor
@Test
func creatingMock() {
    let vc = UIViewController()
    let sut: MockCRIOrchestrator = .make(idCheckJourney: true,
                                         streamContinuation: nil,
                                         hostingViewController: vc)
    
    #expect(sut.idCheckJourney == true)
    #expect(sut.streamContinuation == nil)
    #expect(sut.hostingViewController == vc)
}
