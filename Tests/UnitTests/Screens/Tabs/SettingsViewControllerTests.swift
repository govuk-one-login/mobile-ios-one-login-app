import GDSAnalytics
import GDSCommon
import Networking
@testable import OneLogin
import XCTest

@MainActor
final class SettingsViewControllerTests: XCTestCase {
    private var mockAnalyticsService: MockAnalyticsService!
    private var mockAnalyticsPreference: MockAnalyticsPreferenceStore!
    private var mockSessionManager: MockSessionManager!
    private var mockUrlOpener: MockURLOpener!
    private var viewModel: TabbedViewModel!
    private var sut: SettingsViewController!
    
    private var didTapRow = false
    private var didAppearCalled = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreference = MockAnalyticsPreferenceStore()
        mockSessionManager = MockSessionManager()
        mockUrlOpener = MockURLOpener()
        viewModel = SettingsTabViewModel(analyticsService: mockAnalyticsService,
                                         userProvider: mockSessionManager,
                                         urlOpener: mockUrlOpener,
                                         openSignOutPage: { self.didTapRow = true },
                                         openDeveloperMenu: { })
        sut = SettingsViewController(viewModel: viewModel,
                                     userProvider: mockSessionManager,
                                     analyticsPreference: mockAnalyticsPreference)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        mockAnalyticsPreference = nil
        mockSessionManager = nil
        mockUrlOpener = nil
        viewModel = nil
        sut = nil
        
        didTapRow = false
        didAppearCalled = false
        
        super.tearDown()
    }
}

extension SettingsViewControllerTests {
    func test_numberOfSections() {
        XCTAssertEqual(sut.numberOfSections(in: try sut.tabbedTableView), 6)
    }
    
    func test_numberOfRows() {
        XCTAssertEqual(sut.tableView(try sut.tabbedTableView, numberOfRowsInSection: 0), 2)
    }
    
    func test_navigationViewBackgroundColour() throws {
        XCTAssertEqual(sut.view.backgroundColor, .systemBackground)
    }
    
    func test_rowSelected() throws {
        XCTAssertFalse(didTapRow)
        let indexPath = IndexPath(row: 0, section: 4)
        try sut.tabbedTableView.reloadData()
        sut.tableView(try XCTUnwrap(sut.tabbedTableView), didSelectRowAt: indexPath)
        XCTAssertTrue(didTapRow)
    }
    
    func test_headerConfiguration() throws {
        let header = sut.tableView(try sut.tabbedTableView, viewForHeaderInSection: 1) as? UITableViewHeaderFooterView
        let headerLabel = try XCTUnwrap(header?.textLabel)
        XCTAssertEqual(headerLabel.text, "Help and feedback")
        XCTAssertEqual(headerLabel.font, .bodyBold)
        XCTAssertEqual(headerLabel.textColor, .label)
        XCTAssertTrue(headerLabel.adjustsFontForContentSizeCategory)
    }
    
    func test_cellConfiguration() throws {
        let cell = sut.tableView(try sut.tabbedTableView, cellForRowAt: .first)
        let cellConfig = try XCTUnwrap(cell.contentConfiguration as? UIListContentConfiguration)
        XCTAssertEqual(cellConfig.text, "Your GOV.UK One login")
        XCTAssertEqual(cellConfig.textProperties.color, .label)
        XCTAssertEqual(cellConfig.secondaryText, "")
        XCTAssertEqual(cellConfig.secondaryTextProperties.color, .gdsGrey)
        XCTAssertEqual(cellConfig.image, UIImage(named: "userAccountIcon"))
    }

    func test_cellConfiguration_updateEmail() throws {
        mockSessionManager.user.send(MockUser())
        let cell = sut.tableView(try sut.tabbedTableView, cellForRowAt: .first)
        let cellConfig = try XCTUnwrap(cell.contentConfiguration as? UIListContentConfiguration)
        XCTAssertEqual(cellConfig.text, "Your GOV.UK One login")
        XCTAssertEqual(cellConfig.textProperties.color, .label)
        XCTAssertEqual(cellConfig.secondaryText, "test@example.com")
        XCTAssertEqual(cellConfig.secondaryTextProperties.color, .gdsGrey)
        XCTAssertEqual(cellConfig.image, UIImage(named: "userAccountIcon"))
    }
    
    func test_footerConfiguration() throws {
        let header = sut.tableView(try sut.tabbedTableView, viewForFooterInSection: 0) as? UITableViewHeaderFooterView
        let headerLabel = try XCTUnwrap(header?.textLabel)
        XCTAssertEqual(headerLabel.text, "You might need to sign in again to manage your GOV.UK One Login details.")
        XCTAssertEqual(headerLabel.numberOfLines, 0)
        XCTAssertEqual(headerLabel.lineBreakMode, .byWordWrapping)
        XCTAssertEqual(headerLabel.font, .footnote)
        XCTAssertEqual(headerLabel.textColor, .secondaryLabel)
        XCTAssertTrue(headerLabel.adjustsFontForContentSizeCategory)
    }
    
    func test_screenAnalytics() {
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: SettingsAnalyticsScreenID.settingsScreen.rawValue,
                                screen: SettingsAnalyticsScreen.settingsScreen,
                                titleKey: "app_settingsTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String, OLTaxonomyValue.settings)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String, OLTaxonomyValue.undefined)
    }
    
    func test_updateAnalytics_accepted() {
        mockAnalyticsPreference.hasAcceptedAnalytics = true
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        
        XCTAssertTrue(sut.analyticsSwitch.isOn)
        
        sut.analyticsSwitch.sendActions(for: .valueChanged)
        
        XCTAssertEqual(mockAnalyticsPreference.hasAcceptedAnalytics, false)
    }
    
    func test_updateAnalytics_notAccepted() {
        mockAnalyticsPreference.hasAcceptedAnalytics = false
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        
        XCTAssertFalse(sut.analyticsSwitch.isOn)
        
        sut.analyticsSwitch.sendActions(for: .valueChanged)
        
        XCTAssertEqual(mockAnalyticsPreference.hasAcceptedAnalytics, true)
    }
    
    func test_manageAccount_eventAnalytics() throws {
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        
        let indexPath = IndexPath(row: 1, section: 0)
        try sut.tabbedTableView.reloadData()
        sut.tableView(try XCTUnwrap(sut.tabbedTableView), didSelectRowAt: indexPath)
        
        let event = LinkEvent(textKey: "app_settingsSignInDetailsTile",
                              linkDomain: AppEnvironment.manageAccountURLEnglish.absoluteString,
                              external: .false)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String, OLTaxonomyValue.settings)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String, OLTaxonomyValue.undefined)
    }
    
    func test_helpCell_eventAnalytics() throws {
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        
        let indexPath = IndexPath(row: 0, section: 1)
        try sut.tabbedTableView.reloadData()
        sut.tableView(try XCTUnwrap(sut.tabbedTableView), didSelectRowAt: indexPath)
        
        let event = LinkEvent(textKey: "app_appGuidanceLink",
                              linkDomain: AppEnvironment.appHelpURL.absoluteString,
                              external: .false)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String, OLTaxonomyValue.settings)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String, OLTaxonomyValue.undefined)
    }
    
    func test_contactCell_eventAnalytics() throws {
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        
        let indexPath = IndexPath(row: 1, section: 1)
        try sut.tabbedTableView.reloadData()
        sut.tableView(try XCTUnwrap(sut.tabbedTableView), didSelectRowAt: indexPath)
        
        let event = LinkEvent(textKey: "app_contactLink",
                              linkDomain: AppEnvironment.contactURL.absoluteString,
                              external: .false)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String, OLTaxonomyValue.settings)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String, OLTaxonomyValue.undefined)
    }
    
    func test_privacyNoticeCell_eventAnalytics() throws {
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        
        let indexPath = IndexPath(row: 0, section: 3)
        try sut.tabbedTableView.reloadData()
        sut.tableView(try XCTUnwrap(sut.tabbedTableView), didSelectRowAt: indexPath)
        
        let event = LinkEvent(textKey: "app_privacyNoticeLink2",
                              linkDomain: AppEnvironment.privacyPolicyURL.absoluteString,
                              external: .false)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String, OLTaxonomyValue.settings)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String, OLTaxonomyValue.undefined)
    }
    
    func test_accessibilityCell_eventAnalytics() throws {
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        
        let indexPath = IndexPath(row: 1, section: 3)
        try sut.tabbedTableView.reloadData()
        sut.tableView(try XCTUnwrap(sut.tabbedTableView), didSelectRowAt: indexPath)
        
        let event = LinkEvent(textKey: "app_accessibilityStatement",
                              linkDomain: AppEnvironment.accessibilityStatementURL.absoluteString,
                              external: .false)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String, OLTaxonomyValue.settings)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String, OLTaxonomyValue.undefined)
    }
    
    func test_signOut_eventAnalytics() throws {
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        
        let indexPath = IndexPath(row: 0, section: 4)
        try sut.tabbedTableView.reloadData()
        sut.tableView(try XCTUnwrap(sut.tabbedTableView), didSelectRowAt: indexPath)
        
        let event = ButtonEvent(textKey: "app_signOutButton")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String, OLTaxonomyValue.settings)
        XCTAssertEqual(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String, OLTaxonomyValue.undefined)
    }
}

extension SettingsViewController {
    var tabbedTableView: UITableView {
        get throws {
            try XCTUnwrap(view[child: "tabbed-view-table-view"])
        }
    }
}
