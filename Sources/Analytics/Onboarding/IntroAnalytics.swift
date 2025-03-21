import GDSAnalytics
import Logging

enum IntroAnalyticsScreen: String, OneLoginScreenType {
    case welcome = "introWelcomeScreen"
    case splash = "splashScreen"
    case loginLoading = "loginloadingScreen"
    case updateApp = "updateAppScreen"
}

enum IntroAnalyticsScreenID: String {
    case welcome = "30a6b339-75a8-44a2-a79a-e108546419bf"
    case splash = "3e95fe16-7ba7-4f46-a22e-4ae17112debf"
    case loginLoading = "0672f0fa-8126-479b-b191-8e750fa3d909"
    case updateApp = "ae56a0d6-072a-406f-84c7-83759aa4f942"
}
