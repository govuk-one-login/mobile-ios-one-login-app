import Foundation
import GDSCommon
import UIKit

struct TabbedViewSectionFactory {
    static let linkDisclosureArrow: String = "arrow.up.right"
    
    @MainActor
    static func homeSections(coordinator: HomeCoordinator) -> [TabbedViewSectionModel] {
#if DEBUG
        let homeSection = createSection(header: "Developer Menu",
                                        footer: nil,
                                        cellModels: [.init(cellTitle: "Developer Menu") {
            coordinator.showDeveloperMenu()
        }])
#else
        let homeSection = TabbedViewSectionModel()
#endif
        return [homeSection]
    }
    
    static func profileSections(urlOpener: URLOpener, action: @escaping () -> Void) -> [TabbedViewSectionModel] {
        let manageDetailsSection = createSection(header: "app_profileSubtitle1",
                                                 footer: "app_manageSignInDetailsFootnote",
                                                 cellModels: [.init(cellTitle: "app_manageSignInDetailsLink",
                                                                    accessoryView: linkDisclosureArrow) {
            urlOpener.open(url: AppEnvironment.manageAccountURL)
        }])
        
        let legalSection = createSection(header: "app_profileSubtitle2",
                                         footer: nil,
                                         cellModels: [.init(cellTitle: "app_privacyNoticeLink2",
                                                            accessoryView: linkDisclosureArrow) {
            urlOpener.open(url: AppEnvironment.privacyPolicyURL)
        }])
        
        let helpSection = createSection(header: "app_profileSubtitle3",
                                        footer: nil,
                                        cellModels: [.init(cellTitle: "app_reportAProblemGiveFeedbackLink",
                                                           accessoryView: linkDisclosureArrow),
                                                     .init(cellTitle: "app_appGuidanceLink",
                                                           accessoryView: linkDisclosureArrow)])
        let signoutSection = createSection(header: nil,
                                           footer: nil,
                                           cellModels: [.init(cellTitle: "app_signOutButton",
                                                              textColor: .gdsRed) {
            action()
        }])
        
        return [manageDetailsSection,
                legalSection,
                helpSection,
                signoutSection]
    }
    
    static func createSection(header: GDSLocalisedString?,
                              footer: GDSLocalisedString?,
                              cellModels: [TabbedViewCellModel]) -> TabbedViewSectionModel {
        
        return TabbedViewSectionModel(sectionTitle: header,
                                      sectionFooter: footer,
                                      tabModels: cellModels)
        
    }
}
