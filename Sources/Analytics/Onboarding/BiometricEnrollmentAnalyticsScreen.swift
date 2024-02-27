import GDSAnalytics
import Logging

enum BiometricEnrollmentAnalyticsScreen: String, LoggableScreen, NamedScreen {
    case faceIDEnrollment = "faceIDEnrollmentScreen"
    case touchIDEnrollment = "touchIDEnrollmentScreen"
    case unlockScreen = "unlockScreen"
}
