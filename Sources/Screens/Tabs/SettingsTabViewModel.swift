import GDSAnalytics
import GDSCommon
import Logging
import UIKit

@MainActor
struct SettingsTabViewModel: TabbedViewModel {
    let navigationTitle: GDSLocalisedString = "app_settingsTitle"
    var sectionModels: [TabbedViewSectionModel] {[
        .manageDetails(urlOpener: urlOpener,
                       userEmail: userProvider.user.value?.email ?? "",
                       analyticsService: analyticsService),
        .help(urlOpener: urlOpener,
              analyticsService: analyticsService),
        .analyticsToggle(),
        .notices(urlOpener: urlOpener,
                 analyticsService: analyticsService),
        .signOutSection(analyticsService: analyticsService,
                        action: openSignOutPage),
        .developer(action: openDeveloperMenu)
    ]}
    
    let analyticsService: OneLoginAnalyticsService
    private let urlOpener: URLOpener
    private let userProvider: UserProvider
    let openDeveloperMenu: () -> Void
    let openSignOutPage: () -> Void
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    @MainActor
    init(analyticsService: OneLoginAnalyticsService,
         userProvider: UserProvider,
         urlOpener: URLOpener,
         openSignOutPage: @escaping () -> Void,
         openDeveloperMenu: @escaping () -> Void) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.settings,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        self.userProvider = userProvider
        self.urlOpener = urlOpener
        self.openDeveloperMenu = openDeveloperMenu
        self.openSignOutPage = openSignOutPage
    }
    
    func didAppear() {
        let screen = ScreenView(id: SettingsAnalyticsScreenID.settingsScreen.rawValue,
                                screen: SettingsAnalyticsScreen.settingsScreen,
                                titleKey: navigationTitle.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* protocol conformance */ }
}
