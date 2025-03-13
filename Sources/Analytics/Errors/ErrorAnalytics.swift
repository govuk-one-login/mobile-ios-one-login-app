import GDSAnalytics
import Logging

enum ErrorAnalyticsScreen: String, OneLoginScreenType {
    case appUnavailable = "appUnavailableScreen"
    case generic = "genericErrorScreen"
    case unableToLogin = "unableToLoginErrorScreen"
    case networkConnection = "networkConnectionErrorScreen"
    case signOutWarning = "signOutWarningScreen"
    case signOut = "signOutErrorScreen"
}

enum ErrorAnalyticsScreenID: String {
    case appUnavailable = "d21ab1f2-9b2f-43cd-a2f4-3da0c5c611ea"
    case generic = "f275a786-7366-4ef5-b24b-9e514d324403"
    case networkConnection = "80606f36-f6aa-4f49-aaa8-ff7d3cdeb16f"
    case unableToLogin = "6c15e073-d1a5-4781-b416-aaad6e80b078"
    case signOutWarning = "cfc50baa-4b56-4170-9707-cd05b60b6658"
    case signOut = "5a6c32cd-56e3-4fa6-a135-4fce114d60e9"
}
