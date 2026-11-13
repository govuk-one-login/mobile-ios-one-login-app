import CRIOrchestrator
import CRIOrchestratorInterface
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
struct MockCRIOrchestratorTests {
    @Test
    func creatingMock() {
        let viewController = UIViewController()
        let sut: MockCRIOrchestrator = .make(
            idCheckJourney: true,
            streamContinuation: nil,
            hostingViewController: viewController
        )
        
        #expect(sut.idCheckJourney == true)
        #expect(sut.streamContinuation == nil)
        #expect(sut.hostingViewController == viewController)
    }

    @Test
    func idCheckCardIsDisplayed() {
        let viewController = UIViewController()
        let sut: MockCRIOrchestrator = .make(
            idCheckJourney: false,
            streamContinuation: nil,
            hostingViewController: viewController
        )
        
        let card = sut.getIDCheckCard(
            viewController: viewController,
            externalStream: AsyncStream.makeStream(of: CardStatus.self)
        )
        
        #expect(card.view.isHidden == true)
    }
    
    @Test
    func idCheckCardIsNotDisplayed() {
        let viewController = UIViewController()
        let sut: MockCRIOrchestrator = .make(
            idCheckJourney: true,
            streamContinuation: nil,
            hostingViewController: viewController
        )
        
        let card = sut.getIDCheckCard(
            viewController: viewController,
            externalStream: AsyncStream.makeStream(of: CardStatus.self)
        )
        
        #expect(card.view.isHidden == false)
    }
    
    @Test
    func idCheckModalIsNotDisplayed() {
        let navigationController = MockNavigationController()
        let sut: MockCRIOrchestrator = .make(
            idCheckJourney: true,
            streamContinuation: nil,
            hostingViewController: navigationController
        )
        
        sut.continueIdentityCheckIfRequired(over: navigationController)
        
        #expect(navigationController.isPresented == false)
    }
}

final class MockNavigationController: UINavigationController {
    var isPresented: Bool = false
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        isPresented = true
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: false)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        super.popViewController(animated: false)
    }
}
