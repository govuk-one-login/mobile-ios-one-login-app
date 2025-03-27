import Foundation

protocol LocalAuthPromptRecorder {
    var previouslyPrompted: Bool { get }
    func recordPrompt()
}

extension UserDefaults: LocalAuthPromptRecorder {
    var previouslyPrompted: Bool {
        guard let prompt = value(forKey: "localAuthPrompted") as? Bool else {
            return false
        }
        return prompt
    }
    
    func recordPrompt() {
        set(true, forKey: "localAuthPrompted")
    }
}
