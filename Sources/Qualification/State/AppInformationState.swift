enum AppInformationState {
    case appOffline
    case appInfoError
    case appOutdated
    case appUnconfirmed
    case appConfirmed
    // TODO: DCMAW-9824 - New state may be needed for appInfo.allowAppUsage which corresponds to 'available' in appInfo json
}
