import Foundation
import GDSCommon
import Logging
import UIKit

@MainActor
extension TabbedViewSectionModel {
    static let linkDisclosureArrow: String = "arrow.up.right"
    
    static func manageDetails(urlOpener: URLOpener, userEmail: String) -> Self {
        return TabbedViewSectionModel(sectionTitle: nil,
                                      sectionFooter: "app_settingsSignInDetailsFootnote",
                                      tabModels: [.init(cellTitle: "app_settingsSignInDetailsTile",
                                                        cellSubtitle: userEmail,
                                                        image: UIImage(named: "userAccountIcon")),
                                                  .init(cellTitle: "app_settingsSignInDetailsLink",
                                                        accessoryView: linkDisclosureArrow) {
            urlOpener.open(url: AppEnvironment.manageAccountURL)
        }])
    }
    
    static func help(urlOpener: URLOpener) -> Self {
        return TabbedViewSectionModel(sectionTitle: "app_settingsSubtitle1",
                                      sectionFooter: nil,
                                      tabModels: [.init(cellTitle: "app_appGuidanceLink",
                                                        accessoryView: linkDisclosureArrow) {
            urlOpener.open(url: AppEnvironment.appHelpURL)
        },
                                                  .init(cellTitle: "app_contactLink",
                                                        accessoryView: linkDisclosureArrow) {
            urlOpener.open(url: AppEnvironment.contactURL)
        }])
    }
    
    static func analyticsToggle() -> Self {
        TabbedViewSectionModel(sectionTitle: "app_settingsSubtitle2",
                               sectionFooter: "app_settingsAnalyticsToggleFootnote",
                               tabModels: [.init(cellTitle: "app_settingsAnalyticsToggle")])
    }
    
    static func notices(urlOpener: URLOpener) -> Self {
        return TabbedViewSectionModel(sectionTitle: nil,
                                      sectionFooter: nil,
                                      tabModels: [.init(cellTitle: "app_privacyNoticeLink2",
                                                        accessoryView: linkDisclosureArrow) {
            urlOpener.open(url: AppEnvironment.privacyPolicyURL)
        },
                                                  .init(cellTitle: "app_accessibilityStatement",
                                                        accessoryView: linkDisclosureArrow) {
            urlOpener.open(url: AppEnvironment.accessibilityStatementURL)
        }])
    }
    
    static func signOutSection(action: @escaping () -> Void) -> Self {
        return TabbedViewSectionModel(sectionTitle: nil,
                                      sectionFooter: nil,
                                      tabModels: [.init(cellTitle: "app_signOutButton",
                                                        textColor: .gdsGreen,
                                                        action: action)])
    }
    
    static func developer(action: @escaping () -> Void) -> Self {
        #if DEBUG
        return TabbedViewSectionModel(sectionTitle: "Developer Menu",
                                      sectionFooter: nil,
                                      tabModels: [.init(cellTitle: "Developer Menu",
                                                        action: action)])
        #else
        return TabbedViewSectionModel(tabModels: [])
        #endif
    }
}
