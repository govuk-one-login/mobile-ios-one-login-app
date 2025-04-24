import GDSCommon
import LocalAuthenticationWrapper
import UIKit

struct ScreenBody: ScreenBodyItem {
    var uiView: UIView = ListView(viewModel: NumberedListViewModel())
}

struct NumberedListViewModel: ListViewModel {
    var title: GDSLocalisedString? = "app_localAuthManagerErrorBody3"
    var titleConfig: TitleConfig?
    var listItemStrings: [GDSLocalisedString] = [
        determineLocalAuthString(),
        "app_localAuthManagerErrorNumberedList2",
        "app_localAuthManagerErrorNumberedList3"
    ]
    
    static func determineLocalAuthString() -> GDSLocalisedString {
        return ""
    }
}
