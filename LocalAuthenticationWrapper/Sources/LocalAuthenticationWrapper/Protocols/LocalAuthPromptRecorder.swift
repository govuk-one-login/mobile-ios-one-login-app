import Foundation

protocol LocalAuthPromptRecorder {
    var previouslyPrompted: Bool { get }
    var previouslyPasscodePrompted: Bool { get }
    func recordPrompt()
    func recordPasscodePrompt()
}

extension UserDefaults: LocalAuthPromptRecorder {
    var previouslyPrompted: Bool {
        bool(forKey: "localAuthPrompted")
    }
    
    func recordPrompt() {
        set(true, forKey: "localAuthPrompted")
    }
    
    var previouslyPasscodePrompted: Bool {
        bool(forKey: "localAuthPasscodePrompted")
    }
    
    func recordPasscodePrompt() {
        set(true, forKey: "localAuthPasscodePrompted")
    }
}
