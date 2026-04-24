import Coordination

class MockChildCoordinatorExpectation: ChildCoordinator {

    weak var parentCoordinator: (any Coordination.ParentCoordinator)?

    typealias StartAsFunction = () -> Void
    typealias FinishAsFunction = () -> Void

    var startAsFunction: StartAsFunction
    var finishAsFunction: FinishAsFunction

    init(startAsFunction: @escaping StartAsFunction = {}, finishAsFunction: @escaping FinishAsFunction = {}) {
        self.startAsFunction = startAsFunction
        self.finishAsFunction = finishAsFunction
    }

    func start() {
        self.startAsFunction()
    }

    func finish() {
        self.finishAsFunction()
    }
}
