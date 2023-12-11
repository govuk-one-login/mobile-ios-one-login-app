import GDSAnalytics
import Logging

enum IntroAnalyticsScreen: String, LoggableScreen, NamedScreen {
    case welcomeScreen = "introWelcomeScreen"
}

enum ErrorAnalyticsScreen: String, LoggableScreen, NamedScreen {
    case generic = "genericErrorScreen"
}
