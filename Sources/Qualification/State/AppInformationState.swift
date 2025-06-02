enum AppInformationState {
    /// Initial state of app while `/appInfo` JSON is fetched
    case notChecked
    /// Network not connected
    case offline
    /// All non-successful server responses & any other error fetching `/appInfo` JSON
    case error
    /// App is marked as unavailable in `/appInfo` JSON
    case unavailable
    /// App version is below that defined in `/appInfo` JSON
    case outdated
    /// Allowed to proceed to user checks
    case qualified
    // TODO: DCMAW-9824 - New state may be needed for appInfo.allowAppUsage which corresponds to 'available' in appInfo json
}
