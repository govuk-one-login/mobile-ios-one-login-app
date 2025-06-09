import GDSCommon
import LocalAuthentication
import LocalAuthenticationWrapper
import UIKit

@MainActor
struct LocalAuthErrorListView: ScreenBodyItem {
    let uiView: UIView
    
    init(localAuthType: LocalAuthType) {
        let localAuthErrorBulletViewModel = LocalAuthErrorListViewModel(localAuthType: localAuthType)
        self.uiView = ListView(viewModel: localAuthErrorBulletViewModel)
    }
}

struct LocalAuthErrorListViewModel: ListViewModel {
    let title: GDSLocalisedString? = "app_localAuthManagerErrorBody3"
    let titleConfig: TitleConfig? = (font: .body, isHeader: false)
    let listItemStrings: [GDSLocalisedString]
    
    init(localAuthType: LocalAuthType) {
        self.listItemStrings = [
            LocalAuthErrorListViewModel.determineLocalAuthString(localAuthContext: localAuthType),
            GDSLocalisedString(stringLiteral: "app_localAuthManagerErrorNumberedList2",
                               attributes: [("Turn Passcode On", [.font: UIFont.bodyBold])]),
            GDSLocalisedString(stringKey: "app_localAuthManagerErrorNumberedList3",
                               "app_walletString")
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
