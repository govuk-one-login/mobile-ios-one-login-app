import Foundation

protocol LocalAuthPromptRecorder {
    var previouslyPrompted: Bool { get }
    func recordPrompt()
}

extension UserDefaults: LocalAuthPromptRecorder {
    var previouslyPrompted: Bool {
        bool(forKey: "localAuthPrompted")
    }
    
    func recordPrompt() {
        set(true, forKey: "localAuthPrompted")
    }
}
