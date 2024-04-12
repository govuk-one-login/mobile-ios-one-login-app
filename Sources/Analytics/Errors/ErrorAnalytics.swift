import GDSAnalytics
import Logging

enum ErrorAnalyticsScreen: String, ScreenType {
    case generic = "genericErrorScreen"
    case unableToLogin = "unableToLoginErrorScreen"
    case networkConnection = "networkConnectionErrorScreen"
}

enum ErrorAnalyticsScreenID: String {
    case generic = "f275a786-7366-4ef5-b24b-9e514d324403"
    case networkConnection = "80606f36-f6aa-4f49-aaa8-ff7d3cdeb16f"
}
