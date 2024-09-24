enum AppInformationState {
    /// Network not connected
    case offline
    /// All non-successful server responses & any other error fetching `/appInfo` JSON
    case error
    /// App version is below that defined in `/appInfo` JSON
    case outdated
    /// Initial state of app while `/appInfo` JSON is fetched
    case notChecked
    /// Allowed to proceed to user checks
    case qualified
    // TODO: DCMAW-9824 - New state may be needed for appInfo.allowAppUsage which corresponds to 'available' in appInfo json
}
