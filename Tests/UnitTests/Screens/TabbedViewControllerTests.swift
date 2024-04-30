import GDSCommon
@testable import OneLogin
import XCTest

final class TabbedViewControllerTests: XCTestCase {

    var sut: TabbedViewController!
    var viewModel: TabbedViewModel!
    
    private var didTapRow = false
    
    override func setUp() {
        viewModel = TabbedViewModel(sectionHeaderTitles: createSectionHeaders(),
        cellModels: createCellModels())
        sut = TabbedViewController(viewModel: viewModel, headerView: UIView())
        sut.loadViewIfNeeded()

    }

    override func tearDown() {
        sut = nil
        viewModel = nil
        didTapRow = false
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
    
    private func createCellModels() -> [[TabbedViewCellModel]] {
        let testModel = TabbedViewCellModel(cellTitle: GDSLocalisedString(stringLiteral: "Test Cell")) {
            self.didTapRow = true
        }
        
        return [[testModel]]
    }
    
    private func createSectionHeaders() -> [GDSLocalisedString] {
        [GDSLocalisedString(stringLiteral: "Test Header")]
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
