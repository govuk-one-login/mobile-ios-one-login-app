import GDSCommon
@testable import OneLogin
import XCTest

final class TabbedViewControllerTests: XCTestCase {

    var viewModel: TabbedViewModel!
    var sut: TabbedViewController!
    
    private var didTapRow = false
    
    override func setUp() {
        viewModel = TabbedViewModel(sectionModels: createSectionModels())
        sut = TabbedViewController(viewModel: viewModel, headerView: UIView())
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        viewModel = nil
        sut = nil
        didTapRow = false
        
        super.tearDown()
    }
    
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
