import DesignSystem
import GDSAnalytics
import Networking
@testable import OneLogin
import Testing
import UIKit

@MainActor
struct SettingsViewControllerTests {
    private var mockAnalyticsService: MockAnalyticsService!
    private var mockAnalyticsPreference: MockAnalyticsPreferenceStore!
    private var mockSessionManager: MockSessionManager!
    private var mockUrlOpener: MockURLOpener!
    private var viewModel: TabbedViewModel!
    private var sut: SettingsViewController!
    
    init() {
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreference = MockAnalyticsPreferenceStore()
        mockSessionManager = MockSessionManager()
        mockUrlOpener = MockURLOpener()
        viewModel = SettingsTabViewModel(analyticsService: mockAnalyticsService,
                                         userProvider: mockSessionManager,
                                         urlOpener: mockUrlOpener,
                                         openSignOutPage: { },
                                         openDeveloperMenu: { })
        sut = SettingsViewController(viewModel: viewModel,
                                     userProvider: mockSessionManager,
                                     analyticsPreference: mockAnalyticsPreference)
    }
}

extension SettingsViewControllerTests {
    @Test
    func test_numberOfSections() throws {
        #expect(sut.numberOfSections(in: try sut.tabbedTableView) == 6)
    }
    
    @Test
    func test_numberOfRows() throws {
        #expect(sut.tableView(try sut.tabbedTableView, numberOfRowsInSection: 0) == 2)
    }
    
    @Test
    func test_navigationViewBackgroundColour() throws {
        #expect(sut.view.backgroundColor == .systemBackground)
    }
    
    @Test
    func test_rowSelected() throws {
        var didTapRow = false
        let viewModel = SettingsTabViewModel(analyticsService: mockAnalyticsService,
                                         userProvider: mockSessionManager,
                                         urlOpener: mockUrlOpener,
                                         openSignOutPage: { didTapRow = true },
                                         openDeveloperMenu: { })
        let sut = SettingsViewController(viewModel: viewModel,
                                     userProvider: mockSessionManager,
                                     analyticsPreference: mockAnalyticsPreference)
        
        #expect(!didTapRow)
        let indexPath = IndexPath(row: 0, section: 4)
        try sut.tabbedTableView.reloadData()
        sut.tableView(try sut.tabbedTableView, didSelectRowAt: indexPath)
        #expect(didTapRow)
    }
    
    @Test
    func test_headerConfiguration() throws {
        let header = sut.tableView(try sut.tabbedTableView, viewForHeaderInSection: 1) as? UITableViewHeaderFooterView
        let headerLabel = try #require(header?.textLabel)
        #expect(headerLabel.text == "Help and feedback")
        #expect(headerLabel.font == .bodyBold)
        #expect(headerLabel.textColor == .label)
        #expect(headerLabel.adjustsFontForContentSizeCategory == true)
    }
    
    @Test
    func test_cellConfiguration() throws {
        let cell = sut.tableView(try sut.tabbedTableView, cellForRowAt: .first)
        let cellConfig = try #require(cell.contentConfiguration as? UIListContentConfiguration)
        #expect(cellConfig.text == "Your GOV.UK One Login")
        #expect(cellConfig.textProperties.color == .label)
        #expect(cellConfig.secondaryText == "")
        #expect(cellConfig.secondaryTextProperties.color == .gdsGrey)
        #expect(cellConfig.image == UIImage(named: "userAccountIcon"))
    }
    
    @Test
    func test_cellConfiguration_updateEmail() throws {
        mockSessionManager.user.send(MockUser())
        let cell = sut.tableView(try sut.tabbedTableView, cellForRowAt: .first)
        let cellConfig = try #require(cell.contentConfiguration as? UIListContentConfiguration)
        #expect(cellConfig.text == "Your GOV.UK One Login")
        #expect(cellConfig.textProperties.color == .label)
        #expect(cellConfig.secondaryText == "test@example.com")
        #expect(cellConfig.secondaryTextProperties.color == .gdsGrey)
        #expect(cellConfig.image == UIImage(named: "userAccountIcon"))
    }
    
    @Test
    func test_footerConfiguration() throws {
        let header = sut.tableView(try sut.tabbedTableView, viewForFooterInSection: 0) as? UITableViewHeaderFooterView
        let headerLabel = try #require(header?.textLabel)
        #expect(headerLabel.text == "You might need to sign in again to manage your GOV.UK One Login details.")
        #expect(headerLabel.numberOfLines == 0)
        #expect(headerLabel.lineBreakMode == .byWordWrapping)
        #expect(headerLabel.font == .footnote)
        #expect(headerLabel.textColor == .secondaryLabel)
        #expect(headerLabel.adjustsFontForContentSizeCategory ==  true                           )
    }
    
    @Test
    func test_screenAnalytics() {
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        #expect(mockAnalyticsService.screenViews.count == 1)
        let screen = ScreenView(id: SettingsAnalyticsScreenID.settingsScreen.rawValue,
                                screen: SettingsAnalyticsScreen.settingsScreen,
                                titleKey: "app_settingsTitle")
        #expect(mockAnalyticsService.screenViews as? [ScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String == OLTaxonomyValue.settings)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String == OLTaxonomyValue.undefined)
    }
    
    @Test
    func test_updateAnalytics_accepted() {
        mockAnalyticsPreference.hasAcceptedAnalytics = true
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        
        #expect(sut.analyticsSwitch.isOn)
        
        sut.analyticsSwitch.sendActions(for: .valueChanged)
        
        #expect(mockAnalyticsPreference.hasAcceptedAnalytics == false)
    }
    
    @Test
    func test_updateAnalytics_notAccepted() {
        mockAnalyticsPreference.hasAcceptedAnalytics = false
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        
        #expect(!sut.analyticsSwitch.isOn)
        
        sut.analyticsSwitch.sendActions(for: .valueChanged)
        
        #expect(mockAnalyticsPreference.hasAcceptedAnalytics == true)
    }
    
    @Test
    func test_manageAccount_eventAnalytics() throws {
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        
        let indexPath = IndexPath(row: 1, section: 0)
        try sut.tabbedTableView.reloadData()
        sut.tableView(try sut.tabbedTableView, didSelectRowAt: indexPath)
        
        let event = LinkEvent(textKey: "app_settingsSignInDetailsTile",
                              variableKeys: "app_nameString",
                              linkDomain: AppEnvironment.manageAccountURL.absoluteString,
                              external: .false)
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String == OLTaxonomyValue.settings)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String == OLTaxonomyValue.undefined)
    }
    
    @Test
    func test_helpCell_eventAnalytics() throws {
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        
        let indexPath = IndexPath(row: 0, section: 1)
        try sut.tabbedTableView.reloadData()
        sut.tableView(try sut.tabbedTableView, didSelectRowAt: indexPath)
        
        let event = LinkEvent(textKey: "app_proveYourIdentityLink",
                              linkDomain: AppEnvironment.appHelpURL.absoluteString,
                              external: .false)
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String == OLTaxonomyValue.settings)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String == OLTaxonomyValue.undefined)
    }
    
    @Test
    func test_addingDocumentsCell_eventAnalytics() throws {
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        
        let indexPath = IndexPath(row: 1, section: 1)
        try sut.tabbedTableView.reloadData()
        sut.tableView(try sut.tabbedTableView, didSelectRowAt: indexPath)
        
        let event = LinkEvent(textKey: "app_addDocumentsLink",
                              linkDomain: AppEnvironment.addingDocumentsURL.absoluteString,
                              external: .false)
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String == OLTaxonomyValue.settings)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String == OLTaxonomyValue.undefined)
    }
    
    @Test
    func test_contactCell_eventAnalytics() throws {
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        
        let indexPath = IndexPath(row: 2, section: 1)
        try sut.tabbedTableView.reloadData()
        sut.tableView(try sut.tabbedTableView, didSelectRowAt: indexPath)
        
        let event = LinkEvent(textKey: "app_contactLink",
                              variableKeys: "app_nameString",
                              linkDomain: AppEnvironment.contactURL.absoluteString,
                              external: .false)
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String == OLTaxonomyValue.settings)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String == OLTaxonomyValue.undefined)
    }
    
    @Test
    func test_privacyNoticeCell_eventAnalytics() throws {
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        
        let indexPath = IndexPath(row: 0, section: 3)
        try sut.tabbedTableView.reloadData()
        sut.tableView(try sut.tabbedTableView, didSelectRowAt: indexPath)
        
        let event = LinkEvent(textKey: "app_privacyNoticeLink2",
                              variableKeys: "app_nameString",
                              linkDomain: AppEnvironment.privacyPolicyURL.absoluteString,
                              external: .false)
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String == OLTaxonomyValue.settings)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String == OLTaxonomyValue.undefined)
    }
    
    @Test
    func test_accessibilityCell_eventAnalytics() throws {
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        
        let indexPath = IndexPath(row: 1, section: 3)
        try sut.tabbedTableView.reloadData()
        sut.tableView(try sut.tabbedTableView, didSelectRowAt: indexPath)
        
        let event = LinkEvent(textKey: "app_accessibilityStatement",
                              linkDomain: AppEnvironment.accessibilityStatementURL.absoluteString,
                              external: .false)
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String == OLTaxonomyValue.settings)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String == OLTaxonomyValue.undefined)
    }
    
    @Test
    func test_termsAndConditions_eventAnalytics() throws {
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        
        let indexPath = IndexPath(row: 2, section: 3)
        try sut.tabbedTableView.reloadData()
        sut.tableView(try sut.tabbedTableView, didSelectRowAt: indexPath)
        
        let event = LinkEvent(textKey: "app_termsAndConditionsLink",
                              linkDomain: AppEnvironment.termsAndConditionsURL.absoluteString,
                              external: .false)
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String == OLTaxonomyValue.settings)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String == OLTaxonomyValue.undefined)
    }
    
    @Test
    func test_signOut_eventAnalytics() throws {
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        
        let indexPath = IndexPath(row: 0, section: 4)
        try sut.tabbedTableView.reloadData()
        sut.tableView(try sut.tabbedTableView, didSelectRowAt: indexPath)
        
        let event = ButtonEvent(textKey: "app_signOutButton")
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String == OLTaxonomyValue.settings)
        #expect(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String == OLTaxonomyValue.undefined)
    }
}

extension SettingsViewController {
    var tabbedTableView: UITableView {
        get throws {
            try #require(view[child: "tabbed-view-table-view"])
        }
    }
}
