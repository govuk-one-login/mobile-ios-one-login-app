import GDSCommon
import LocalAuthentication
import UIKit

struct LocalAuthErrorBulletView: ScreenBodyItem {
    let uiView: UIView = ListView(viewModel: LocalAuthErrorBulletViewModel())
}

struct LocalAuthErrorBulletViewModel: ListViewModel {
    let title: GDSLocalisedString? = "app_localAuthManagerErrorBody3"
    let titleConfig: TitleConfig? = (font: .body, isHeader: false)
    let listItemStrings: [GDSLocalisedString] = [
        determineLocalAuthString(localAuthContext: LAContext()),
        GDSLocalisedString(stringLiteral: "app_localAuthManagerErrorNumberedList2",
                           attributes: [("Turn Passcode On", [.font: UIFont.bodyBold])]),
        "app_localAuthManagerErrorNumberedList3"
    ]

    private static func determineLocalAuthString(localAuthContext: LAContext) -> GDSLocalisedString {
        localAuthContext.biometryType == .faceID ?
        GDSLocalisedString(stringLiteral: "app_localAuthManagerErrorNumberedList1FaceID",
                           attributes: [("Face ID & Passcode", [.font: UIFont.bodyBold])]) :
        GDSLocalisedString(stringLiteral: "app_localAuthManagerErrorNumberedList1TouchID",
                           attributes: [("Touch ID & Passcode", [.font: UIFont.bodyBold])])
    }
}
