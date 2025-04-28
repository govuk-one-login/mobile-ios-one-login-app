import GDSCommon
import LocalAuthentication
import UIKit

struct LocalAuthErrorBulletView: ScreenBodyItem {
    var uiView: UIView = ListView(viewModel: LocalAuthErrorBulletViewModel())
}

struct LocalAuthErrorBulletViewModel: ListViewModel {
    var title: GDSLocalisedString? = "app_localAuthManagerErrorBody3"
    var titleConfig: TitleConfig?
    var listItemStrings: [GDSLocalisedString] = [
        determineLocalAuthString(localAuthContext: LAContext()),
        GDSLocalisedString(stringLiteral: "app_localAuthManagerErrorNumberedList2",
                           attributes: [("Turn Passcode On", [.font: UIFont.bodyBold])]),
        "app_localAuthManagerErrorNumberedList3"
    ]
    let localAuthentication: LocalAuthManaging = LocalAuthenticationWrapper(localAuthStrings: .oneLogin)
    
    private static func determineLocalAuthString(localAuthContext: LAContext) -> GDSLocalisedString {
        localAuthContext.biometryType == .faceID ?
        GDSLocalisedString(stringLiteral: "app_localAuthManagerErrorNumberedList1FaceID",
                           attributes: [("Face ID & Passcode", [.font: UIFont.bodyBold])]) :
        GDSLocalisedString(stringLiteral: "app_localAuthManagerErrorNumberedList1TouchID",
                           attributes: [("Touch ID & Passcode", [.font: UIFont.bodyBold])])
    }
}
