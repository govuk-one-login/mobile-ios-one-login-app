import GDSAnalytics
import Logging

enum SettingsAnalyticsScreen: String, ScreenType {
    case settingsScreen
    case signOutScreenWithWallet
    case signOutScreenNoWallet
}

enum SettingsAnalyticsScreenID: String {
    case settingsScreen = "d6bae235-e427-4e51-8e17-17d2b976a201"
    case signOutScreenWithWallet = "17ab1f34-3d1b-4465-9ce6-fe648c2ff06c"
    case signOutScreenNoWallet = "3e50cd12-4ee8-4787-add8-6a2ac7d4a840"
}

func returnEventLink(indexPath: Int) -> String {
    var str: String
    
    switch indexPath {
    case 1:
        str = AppEnvironment.manageAccountURL.lastPathComponent
    case 2:
        str = AppEnvironment.appHelpURL.lastPathComponent
    case 3:
        str = AppEnvironment.contactURL.lastPathComponent
    case 4:
        str = AppEnvironment.privacyPolicyURL.lastPathComponent
    case 5:
        str = AppEnvironment.accessibilityStatementURL.lastPathComponent
    default:
        str = ""
    }
    return str
}
