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

    static var didLogout: Self {
        Notification.Name("onelogin:logout")
    }
}
