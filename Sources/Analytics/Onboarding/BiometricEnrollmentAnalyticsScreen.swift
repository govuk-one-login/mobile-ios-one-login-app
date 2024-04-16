import GDSAnalytics
import Logging

enum BiometricEnrollmentAnalyticsScreen: String, ScreenType {
    case faceIDEnrollment = "faceIDEnrollmentScreen"
    case touchIDEnrollment = "touchIDEnrollmentScreen"
    case unlockScreen = "unlockScreen"
}

enum BiometricEnrollmentAnalyticsScreenID: String {
    case faceIDEnrollment = "7590abba-f48b-4790-be64-f6ffc3dd35e2"
    case touchIDEnrollment = "cc1db40a-2a5a-43fe-a1fe-fc85b55fdcab"
    case unlockScreen = "d61fcd23-cbcf-4df6-8e9c-d0dec956dbe1"
}
