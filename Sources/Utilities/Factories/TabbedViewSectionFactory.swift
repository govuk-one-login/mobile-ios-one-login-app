import Foundation
import GDSAnalytics
import GDSCommon
import Logging
import UIKit

@MainActor
extension TabbedViewSectionModel {
    static let linkDisclosureArrow: String = "arrow.up.right"
    
    static func manageDetails(urlOpener: URLOpener, userEmail: String, analyticsService: OneLoginAnalyticsService) -> Self {
        return TabbedViewSectionModel(sectionTitle: nil,
                                      sectionFooter: "app_settingsSignInDetailsFootnote",
                                      tabModels: [.init(cellTitle: "app_settingsSignInDetailsTile",
                                                        cellSubtitle: userEmail,
                                                        image: UIImage(named: "userAccountIcon")),
                                                  .init(cellTitle: "app_settingsSignInDetailsLink",
                                                        accessoryView: linkDisclosureArrow,
                                                        accessibilityHint: GDSLocalisedString(stringKey: "app_externalBrowser")) {
            urlOpener.open(url: AppEnvironment.manageAccountURL)
            let event = LinkEvent(textKey: "app_settingsSignInDetailsTile",
                                  linkDomain: AppEnvironment.manageAccountURLEnglish.absoluteString,
                                  external: .false)
            analyticsService.logEvent(event)
        }])
    }
    
    static func help(urlOpener: URLOpener, analyticsService: OneLoginAnalyticsService) -> Self {
        return TabbedViewSectionModel(sectionTitle: "app_settingsSubtitle1",
                                      sectionFooter: nil,
                                      tabModels: [.init(cellTitle: "app_appGuidanceLink",
                                                        accessoryView: linkDisclosureArrow,
                                                        accessibilityHint: GDSLocalisedString(stringKey: "app_externalBrowser")) {
            urlOpener.open(url: AppEnvironment.appHelpURL)
            let event = LinkEvent(textKey: "app_appGuidanceLink",
                                  linkDomain: AppEnvironment.appHelpURL.absoluteString,
                                  external: .false)
            analyticsService.logEvent(event)
        },
                                                  .init(cellTitle: "app_contactLink",
                                                        accessoryView: linkDisclosureArrow,
                                                        accessibilityHint: GDSLocalisedString(stringKey: "app_externalBrowser")) {
            urlOpener.open(url: AppEnvironment.contactURL)
            let event = LinkEvent(textKey: "app_contactLink",
                                  linkDomain: AppEnvironment.contactURL.absoluteString,
                                  external: .false)
            analyticsService.logEvent(event)
        }])
    }
    
    static func analyticsToggle() -> Self {
        TabbedViewSectionModel(sectionTitle: "app_settingsSubtitle2",
                               sectionFooter: "app_settingsAnalyticsToggleFootnote",
                               tabModels: [.init(cellTitle: "app_settingsAnalyticsToggle")])
    }
    
    static func notices(urlOpener: URLOpener, analyticsService: OneLoginAnalyticsService) -> Self {
        return TabbedViewSectionModel(sectionTitle: nil,
                                      sectionFooter: nil,
                                      tabModels: [.init(cellTitle: "app_privacyNoticeLink2",
                                                        accessoryView: linkDisclosureArrow,
                                                        accessibilityHint: GDSLocalisedString(stringKey: "app_externalBrowser")) {
            urlOpener.open(url: AppEnvironment.privacyPolicyURL)
            let event = LinkEvent(textKey: "app_privacyNoticeLink2",
                                  linkDomain: AppEnvironment.privacyPolicyURL.absoluteString,
                                  external: .false)
            analyticsService.logEvent(event)
        },
                                                  .init(cellTitle: "app_accessibilityStatement",
                                                        accessoryView: linkDisclosureArrow,
                                                        accessibilityHint: GDSLocalisedString(stringKey: "app_externalBrowser")) {
            urlOpener.open(url: AppEnvironment.accessibilityStatementURL)
            let event = LinkEvent(textKey: "app_accessibilityStatement",
                                  linkDomain: AppEnvironment.accessibilityStatementURL.absoluteString,
                                  external: .false)
            analyticsService.logEvent(event)
        }])
    }
    
    static func signOutSection(analyticsService: OneLoginAnalyticsService, action: @escaping () -> Void) -> Self {
        var analyticsService = analyticsService
        return TabbedViewSectionModel(sectionTitle: nil,
                                      sectionFooter: nil,
                                      tabModels: [.init(cellTitle: "app_signOutButton",
                                                        textColor: .gdsGreen) {
            action()
            let event = ButtonEvent(textKey: "app_signOutButton")
            analyticsService.logEvent(event)
        }])
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
