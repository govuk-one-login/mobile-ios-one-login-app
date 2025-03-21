import GDSAnalytics
import Logging

enum BiometricEnrolmentAnalyticsScreen: String, OneLoginScreenType {
    case faceIDEnrolment = "faceIDEnrollmentScreen"
    case touchIDEnrolment = "touchIDEnrollmentScreen"
    case unlock = "unlockScreen"
}

enum BiometricEnrolmentAnalyticsScreenID: String {
    case faceIDEnrolment = "7590abba-f48b-4790-be64-f6ffc3dd35e2"
    case touchIDEnrolment = "cc1db40a-2a5a-43fe-a1fe-fc85b55fdcab"
    case unlock = "d61fcd23-cbcf-4df6-8e9c-d0dec956dbe1"
}
