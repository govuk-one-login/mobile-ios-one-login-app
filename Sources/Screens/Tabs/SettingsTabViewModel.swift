import DesignSystem
import GDSAnalytics
import Logging
import UIKit

@MainActor
struct SettingsTabViewModel: TabbedViewModel {
    let navigationTitle: GDSLocalisedString
    var sectionModels: [TabbedViewSectionModel] {
        var sections: [TabbedViewSectionModel] = [
            .manageDetails(urlOpener: urlOpener,
                           userEmail: userProvider.user.value?.email ?? "",
                           analyticsService: analyticsService),
            .help(urlOpener: urlOpener,
                  analyticsService: analyticsService),
            .analyticsToggle(),
            .notices(urlOpener: urlOpener,
                     analyticsService: analyticsService),
            .signOutSection(analyticsService: analyticsService,
                            action: openSignOutPage)
        ]
        #if DEBUG
        sections.append(.developer(action: openDeveloperMenu))
        #endif
        return sections
    }
    
    let analyticsService: OneLoginAnalyticsService
    private let urlOpener: URLOpener
    private let userProvider: UserProvider
    let openDeveloperMenu: () -> Void
    let openSignOutPage: () -> Void
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    let backButtonTitle: GDSLocalisedString? = nil
    let didAppear: DesignSystem.Action?
    let didDismiss: DesignSystem.Action? = nil
    
    @MainActor
    init(analyticsService: OneLoginAnalyticsService,
         userProvider: UserProvider,
         urlOpener: URLOpener,
         openSignOutPage: @escaping () -> Void,
         openDeveloperMenu: @escaping () -> Void) {
        let analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.settings,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        let navigationTitle: GDSLocalisedString = "app_settingsTitle"
        self.navigationTitle = navigationTitle
        self.analyticsService = analyticsService
        self.userProvider = userProvider
        self.urlOpener = urlOpener
        self.openDeveloperMenu = openDeveloperMenu
        self.openSignOutPage = openSignOutPage
        self.didAppear = .action({
            let screen = ScreenView(id: SettingsAnalyticsScreenID.settingsScreen.rawValue,
                                    screen: SettingsAnalyticsScreen.settingsScreen,
                                    titleKey: navigationTitle.stringKey)
            analyticsService.trackScreen(screen)
        })
    }
}
