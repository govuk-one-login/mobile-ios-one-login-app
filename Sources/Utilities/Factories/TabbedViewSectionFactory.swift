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
                                      sectionFooter: GDSLocalisedString(stringKey: "app_settingsSignInDetailsFootnote",
                                                                        "app_nameString"),
                                      tabModels: [.init(cellTitle: GDSLocalisedString(stringKey: "app_settingsSignInDetailsTile",
                                                                                      "app_nameString"),
                                                        cellSubtitle: userEmail,
                                                        image: UIImage(named: "userAccountIcon")),
                                                  .init(cellTitle: "app_settingsSignInDetailsLink",
                                                        accessoryView: linkDisclosureArrow,
                                                        accessibilityHint: GDSLocalisedString(stringKey: "app_externalBrowser")) {
            urlOpener.open(url: AppEnvironment.manageAccountURL)
            let event = LinkEvent(textKey: "app_settingsSignInDetailsTile",
                                  variableKeys: "app_nameString",
                                  linkDomain: AppEnvironment.manageAccountURL.absoluteString,
                                  external: .false)
            analyticsService.logEvent(event)
        }])
    }
    
    static func help(urlOpener: URLOpener, analyticsService: OneLoginAnalyticsService) -> Self {
        return TabbedViewSectionModel(sectionTitle: "app_settingsSubtitle1",
                                      sectionFooter: nil,
                                      tabModels: [.init(cellTitle: "app_proveYourIdentityLink",
                                                        accessoryView: linkDisclosureArrow,
                                                        accessibilityHint: GDSLocalisedString(stringKey: "app_externalBrowser")) {
            urlOpener.open(url: AppEnvironment.appHelpURL)
            let event = LinkEvent(textKey: "app_proveYourIdentityLink",
                                  linkDomain: AppEnvironment.appHelpURL.absoluteString,
                                  external: .false)
            analyticsService.logEvent(event)
        },
                                                  .init(cellTitle: "app_addDocumentsLink",
                                                        accessoryView: linkDisclosureArrow,
                                                        accessibilityHint: GDSLocalisedString(stringKey: "app_externalBrowser")) {
            urlOpener.open(url: AppEnvironment.addingDocumentsURL)
            let event = LinkEvent(textKey: "app_addDocumentsLink",
                                  linkDomain: AppEnvironment.addingDocumentsURL.absoluteString,
                                  external: .false)
            analyticsService.logEvent(event)
        },
                                                  .init(cellTitle: GDSLocalisedString(stringKey: "app_contactLink",
                                                                                      "app_nameString"),
                                                        accessoryView: linkDisclosureArrow,
                                                        accessibilityHint: GDSLocalisedString(stringKey: "app_externalBrowser")) {
            urlOpener.open(url: AppEnvironment.contactURL)
            let event = LinkEvent(textKey: "app_contactLink",
                                  variableKeys: "app_nameString",
                                  linkDomain: AppEnvironment.contactURL.absoluteString,
                                  external: .false)
            analyticsService.logEvent(event)
        }])
    }
    
    static func analyticsToggle() -> Self {
        TabbedViewSectionModel(sectionTitle: "app_settingsSubtitle2",
                               sectionFooter: GDSLocalisedString(stringKey: "app_settingsAnalyticsToggleFootnote",
                                                                 "app_nameString",
                                                                 "app_nameString"),
                               tabModels: [.init(cellTitle: "app_settingsAnalyticsToggle")])
    }
    
    static func notices(urlOpener: URLOpener, analyticsService: OneLoginAnalyticsService) -> Self {
        return TabbedViewSectionModel(sectionTitle: nil,
                                      sectionFooter: nil,
                                      tabModels: [.init(cellTitle: GDSLocalisedString(stringKey: "app_privacyNoticeLink2",
                                                                                      "app_nameString"),
                                                        accessoryView: linkDisclosureArrow,
                                                        accessibilityHint: GDSLocalisedString(stringKey: "app_externalBrowser")) {
            urlOpener.open(url: AppEnvironment.privacyPolicyURL)
            let event = LinkEvent(textKey: "app_privacyNoticeLink2",
                                  variableKeys: "app_nameString",
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
        },
                                                  .init(cellTitle: "app_termsAndConditionsLink",
                                                        accessoryView: linkDisclosureArrow,
                                                        accessibilityHint: GDSLocalisedString(stringKey: "app_externalBrowser")) {
            urlOpener.open(url: AppEnvironment.termsAndConditionsURL)
            let event = LinkEvent(textKey: "app_termsAndConditionsLink",
                                  linkDomain: AppEnvironment.termsAndConditionsURL.absoluteString,
                                  external: .false)
            analyticsService.logEvent(event)
        }])
    }
    
    static func signOutSection(analyticsService: OneLoginAnalyticsService, action: @escaping () -> Void) -> Self {
        return TabbedViewSectionModel(sectionTitle: nil,
                                      sectionFooter: nil,
                                      tabModels: [.init(cellTitle: "app_signOutButton",
                                                        textColor: .accent) {
            action()
            let event = ButtonEvent(textKey: "app_signOutButton")
            analyticsService.logEvent(event)
        }])
    }
    
    static func developer(action: @escaping () -> Void) -> Self {
        return TabbedViewSectionModel(sectionTitle: "Developer Menu",
                                      sectionFooter: nil,
                                      tabModels: [.init(cellTitle: "Developer Menu",
                                                        action: action)])
    }
}
