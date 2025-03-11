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
    
    let analyticsService: AnalyticsService
    private let urlOpener: URLOpener
    private let userProvider: UserProvider
    private let openDeveloperMenu: () -> Void
    private let openSignOutPage: () -> Void
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    
    @MainActor
    init(analyticsService: AnalyticsService,
         userProvider: UserProvider,
         urlOpener: URLOpener = UIApplication.shared,
         openSignOutPage: @escaping () -> Void,
         openDeveloperMenu: @escaping () -> Void) {
        var tempAnalyticsService = analyticsService
        tempAnalyticsService.setAdditionalParameters(appTaxonomy: .settings)
        self.analyticsService = tempAnalyticsService
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
