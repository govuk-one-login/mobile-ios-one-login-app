import GDSAnalytics
import Logging

enum BiometricEnrollmentAnalyticsScreen: String, ScreenType {
    case faceIDEnrollment = "faceIDEnrollmentScreen"
    case touchIDEnrollment = "touchIDEnrollmentScreen"
    case unlockScreen = "unlockScreen"
}
