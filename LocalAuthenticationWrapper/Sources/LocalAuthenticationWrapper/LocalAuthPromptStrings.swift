public struct LocalAuthPromptStrings {
    let faceIdSubtitle: String
    let touchIdSubtitle: String
    let passcodeButton: String
    let cancelButton: String
    
    public init(
        faceIdSubtitle: String,
        touchIdSubtitle: String,
        passcodeButton: String,
        cancelButton: String
    ) {
        self.faceIdSubtitle = faceIdSubtitle
        self.touchIdSubtitle = touchIdSubtitle
        self.passcodeButton = passcodeButton
        self.cancelButton = cancelButton
    }
}
