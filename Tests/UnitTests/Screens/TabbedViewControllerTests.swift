import GDSAnalytics
import GDSCommon
import Networking
@testable import OneLogin
import XCTest

@MainActor
final class TabbedViewControllerTests: XCTestCase {
    private var mockAnalyticsService: MockAnalyticsService!
    private var mockSessionManager: MockSessionManager!
    private var viewModel: TabbedViewModel!
    private var sut: TabbedViewController!

    private var didTapRow = false
    private var didAppearCalled = false


    override func setUp() {
        super.setUp()

        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()
        viewModel = MockTabbedViewModel(analyticsService: mockAnalyticsService,
                                        navigationTitle: "Test Navigation Title",
                                        sectionModels: createSectionModels()) {
            self.didAppearCalled = true
        }
        sut = TabbedViewController(viewModel: viewModel,
                                   userProvider: mockSessionManager,
                                   headerView: UIView())
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        mockSessionManager = nil
        viewModel = nil
        sut = nil
        
        didTapRow = false
        didAppearCalled = false
        
        super.tearDown()
    }
}

extension TabbedViewControllerTests {
    func test_numberOfSections() {
        XCTAssertEqual(sut.numberOfSections(in: try sut.tabbedTableView), 1)
    }
    
    func test_numberOfRows() {
        XCTAssertEqual(sut.tableView(try sut.tabbedTableView, numberOfRowsInSection: 0), 1)
    }
    
    func test_rowSelected() throws {
        XCTAssertFalse(didTapRow)
        let indexPath = IndexPath(row: 0, section: 0)
        try sut.tabbedTableView.reloadData()
        sut.tableView(try XCTUnwrap(sut.tabbedTableView), didSelectRowAt: indexPath)
        XCTAssertTrue(didTapRow)
    }
    
    func test_headerConfiguration() throws {
        try sut.tabbedTableView.reloadData()
        let header = sut.tableView(try sut.tabbedTableView, viewForHeaderInSection: 0) as? UITableViewHeaderFooterView
        let headerLabel = try XCTUnwrap(header?.textLabel)
        XCTAssertEqual(headerLabel.text, "Test Header")
        XCTAssertEqual(headerLabel.font, .bodyBold)
        XCTAssertEqual(headerLabel.textColor, .label)
        XCTAssertTrue(headerLabel.adjustsFontForContentSizeCategory)
    }
    
    func test_cellConfiguration() throws {
        try sut.tabbedTableView.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = sut.tableView(try sut.tabbedTableView, cellForRowAt: indexPath)
        let cellLabel = try XCTUnwrap(cell.textLabel)
        XCTAssertEqual(cellLabel.text, "Test Cell")
        XCTAssertEqual(cellLabel.font.familyName, UIFont.body.familyName)
        XCTAssertEqual(cellLabel.textColor, .systemRed)
        XCTAssertTrue((cell.accessoryView as? UIImageView)?.image != nil)
        XCTAssertEqual(cell.accessoryView?.tintColor, .secondaryLabel)
    }
    
    func test_footerConfiguration() throws {
        try sut.tabbedTableView.reloadData()
        let header = sut.tableView(try sut.tabbedTableView, viewForFooterInSection: 0) as? UITableViewHeaderFooterView
        let headerLabel = try XCTUnwrap(header?.textLabel)
        XCTAssertEqual(headerLabel.text, "Test Footer")
        XCTAssertEqual(headerLabel.numberOfLines, 0)
        XCTAssertEqual(headerLabel.lineBreakMode, .byWordWrapping)
        XCTAssertEqual(headerLabel.font, .footnote)
        XCTAssertEqual(headerLabel.textColor, .secondaryLabel)
        XCTAssertTrue(headerLabel.adjustsFontForContentSizeCategory)
    }

    @MainActor
    func test_updateUser() throws {
        let profileCoordinator = ProfileCoordinator(analyticsService: mockAnalyticsService,
                                                    sessionManager: mockSessionManager,
                                                    networkClient: NetworkClient(),
                                                    urlOpener: MockURLOpener(),
                                                    walletAvailabilityService: MockWalletAvailabilityService())
        let sections = TabbedViewSectionFactory.profileSections(coordinator: profileCoordinator, urlOpener: MockURLOpener()) {

        }
        let viewModel = ProfileTabViewModel(analyticsService: mockAnalyticsService,
                                            sectionModels: sections)
        sut = TabbedViewController(viewModel: viewModel,
                                   userProvider: mockSessionManager,
                                   headerView: SignInView())
        // GIVEN I am not logged in
        XCTAssertEqual(try sut.emailLabel.text, "You’re signed in as\n")
        // WHEN the user is updated
        mockSessionManager.user.send(MockUser())
        // THEN my email is displayed
        let emailLabel = try sut.emailLabel
        waitForTruth(emailLabel.text == "You’re signed in as\ntest@example.com", timeout: 2)
    }

    func test_screenAnalytics() throws {
        sut.screenAnalytics()
        XCTAssertTrue(didAppearCalled)
    }
    
    private func createSectionModels() -> [TabbedViewSectionModel] {
        let testSection = TabbedViewSectionFactory.createSection(header: "Test Header",
                                                                 footer: "Test Footer",
                                                                 cellModels: [.init(cellTitle: "Test Cell",
                                                                                    accessoryView: "arrow.up.right",
                                                                                    textColor: .systemRed) {
            self.didTapRow = true
        }])
        
        return [testSection]
    }
}

extension TabbedViewController {
    var emailLabel: UILabel {
        get throws {
            try XCTUnwrap(view[child: "signin-view-email-label"])
        }
    }
    
    var tabbedTableView: UITableView {
        get throws {
            try XCTUnwrap(view[child: "tabbed-view-table-view"])
        }
    }
}
