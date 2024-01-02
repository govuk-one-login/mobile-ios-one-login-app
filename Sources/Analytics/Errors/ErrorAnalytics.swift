import GDSAnalytics
import Logging

enum ErrorAnalyticsScreen: String, LoggableScreen, NamedScreen {
    case generic = "genericErrorScreen"
    case unableToLogin = "unableToLoginErrorScreen"
    case networkConnection = "networkConnectionErrorScreen"
}
