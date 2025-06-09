import GDSAnalytics
import Logging

enum SettingsAnalyticsScreen: String, OneLoginScreenType {
    case settingsScreen
    case signOutScreenWithWallet
    case signOutScreenNoWallet
    case signOutSuccessfulScreenNoWallet
    case signOutSuccessfulScreenWithWallet
}

enum SettingsAnalyticsScreenID: String {
    case settingsScreen = "d6bae235-e427-4e51-8e17-17d2b976a201"
    case signOutScreenWithWallet = "17ab1f34-3d1b-4465-9ce6-fe648c2ff06c"
    case signOutScreenNoWallet = "3e50cd12-4ee8-4787-add8-6a2ac7d4a840"
    case signOutSuccessfulScreenNoWallet = "8ef6ccc1-7abd-4fbd-b5b5-6368bffe624f"
    case signOutSuccessfulScreenWithWallet = "ea627a8b-1f24-44c3-8540-0684c26d390f"
}
