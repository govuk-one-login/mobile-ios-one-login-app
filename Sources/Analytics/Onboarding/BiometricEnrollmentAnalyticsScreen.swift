import GDSAnalytics
import Logging

enum BiometricEnrollmentAnalyticsScreen: String, ScreenType {
    case faceIDEnrollment = "faceIDEnrollmentScreen"
    case touchIDEnrollment = "touchIDEnrollmentScreen"
    case unlockScreen = "unlockScreen"
}

enum BiometricEnrollmentAnalyticsScreenID: String {
    case touchIDEnrollment = "cc1db40a-2a5a-43fe-a1fe-fc85b55fdcab"
}
