import GDSCommon
import LocalAuthentication
import LocalAuthenticationWrapper
import UIKit

@MainActor
struct LocalAuthErrorBulletView: ScreenBodyItem {
    let uiView: UIView
    
    init(localAuthType: LocalAuthType) {
        let localAuthErrorBulletViewModel = LocalAuthErrorBulletViewModel(localAuthType: localAuthType)
        self.uiView = ListView(viewModel: localAuthErrorBulletViewModel)
    }
}

struct LocalAuthErrorBulletViewModel: ListViewModel {
    let title: GDSLocalisedString? = "app_localAuthManagerErrorBody3"
    let titleConfig: TitleConfig? = (font: .body, isHeader: false)
    let listItemStrings: [GDSLocalisedString]
    
    init(localAuthType: LocalAuthType) {
        self.listItemStrings = [
            LocalAuthErrorBulletViewModel.determineLocalAuthString(localAuthContext: localAuthType),
            GDSLocalisedString(stringLiteral: "app_localAuthManagerErrorNumberedList2",
                               attributes: [("Turn Passcode On", [.font: UIFont.bodyBold])]),
            "app_localAuthManagerErrorNumberedList3"
        ]
    }

    private static func determineLocalAuthString(localAuthContext: LocalAuthType) -> GDSLocalisedString {
        localAuthContext == .faceID ?
        GDSLocalisedString(stringLiteral: "app_localAuthManagerErrorNumberedList1FaceID",
                           attributes: [("Face ID & Passcode", [.font: UIFont.bodyBold])]) :
        GDSLocalisedString(stringLiteral: "app_localAuthManagerErrorNumberedList1TouchID",
                           attributes: [("Touch ID & Passcode", [.font: UIFont.bodyBold])])
    }
}
