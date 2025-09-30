import NotificationCenter

extension NotificationCenter {
    func post(name: Notification.Name) {
        post(name: name, object: nil)
    }
    
    func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name) {
        addObserver(observer, selector: aSelector, name: aName, object: nil)
    }
}

extension Notification.Name {
    static var enrolmentComplete: Self {
        Notification.Name("onelogin:enrolment-complete")
    }
    
    static var sessionExpired: Self {
        Notification.Name("onelogin:session-expired")
    }
    
    /// Posted when a user explicitly opts to log out of the app
    static var userDidLogout: Self {
        Notification.Name("onelogin:user-did-log-out")
    }
    
    /// Posted when the system detects that a user should be automatically logged out
    static var systemLogUserOut: Self {
        Notification.Name("onelogin:system-log-user-out")
    }
}
