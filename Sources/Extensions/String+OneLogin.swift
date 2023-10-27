extension String {
    static var oneLoginClientID: String {
        return AppEnvironment().string(for: .clientId)
    }
    
    static var oneLoginRedirect: String {
        return AppEnvironment().string(for: .redirectURL)
    }
}
