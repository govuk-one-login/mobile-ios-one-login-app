import Foundation
import GDSCommon
import Logging
import UIKit

struct TabbedViewSectionFactory {
    static let linkDisclosureArrow: String = "arrow.up.right"
    
    @MainActor
    static func settingsSections(coordinator: SettingsCoordinator,
                                urlOpener: URLOpener,
                                action: @escaping () -> Void) -> [TabbedViewSectionModel] {
        let manageDetailsSection = createSection(header: nil,
                                                 footer: "app_settingSignInDetailsFootnote",
                                                 cellModels: [.init(cellTitle: "app_settingsSignInDetailsLink",
                                                                    accessoryView: linkDisclosureArrow) {
            urlOpener.open(url: AppEnvironment.manageAccountURL)
        }])
        
        let helpSection = createSection(header: "app_profileSubtitle3",
                                        footer: nil,
                                        cellModels: [.init(cellTitle: "app_appGuidanceLink",
                                                           accessoryView: linkDisclosureArrow),
                                                     .init(cellTitle: "app_contactLink",
                                                                        accessoryView: linkDisclosureArrow)])
        
        let analyticsSection = createSection(header: "app_settingsSubtitle2",
                                             footer: "app_settingsAnalyticsToggleFootnote",
                                             cellModels: [.init(cellTitle: "app_analyticsToggle")])
        
        let noticesSection  = createSection(header: nil,
                                            footer: nil,
                                            cellModels: [.init(cellTitle: "app_privacyNoticeLink2",
                                                               accessoryView: linkDisclosureArrow),
                                                         .init(cellTitle: "app_accessibilityStatement",
                                                               accessoryView: linkDisclosureArrow) {
            action()
        }])
        
        let signoutSection = createSection(header: nil,
                                           footer: nil,
                                           cellModels: [.init(cellTitle: "app_signOutButton",
                                                              textColor: .gdsRed) {
            action()
        }])
        
        #if DEBUG
        let developerSection = createSection(header: "Developer Menu",
                                             footer: nil,
                                             cellModels: [.init(cellTitle: "Developer Menu") {
              coordinator.showDeveloperMenu()
        }])
        #else
        let developerSection = TabbedViewSectionModel()
        #endif
        
        return [manageDetailsSection,
                helpSection,
                analyticsSection,
                noticesSection,
                signoutSection,
                developerSection]
    }
    
    static func createSection(header: GDSLocalisedString?,
                              footer: GDSLocalisedString?,
                              cellModels: [TabbedViewCellModel]) -> TabbedViewSectionModel {
        return TabbedViewSectionModel(sectionTitle: header,
                                      sectionFooter: footer,
                                      tabModels: cellModels)
        
    }
}
