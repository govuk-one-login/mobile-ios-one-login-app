import DesignSystem

public extension DesignSystem.Action {
    func perform() {
        if case let .action(action) = self {
            action()
        }
    }
    
    func performAsync() async {
        switch self {
        case .action(let action):
            action()
        case .asyncAction(let action):
            await action()
        }
    }
}
