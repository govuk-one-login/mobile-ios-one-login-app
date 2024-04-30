import MockNetworking
@testable import Networking
@testable import OneLogin
import XCTest

final class DeveloperMenuViewControllerTests: XCTestCase {
    var sut: DeveloperMenuViewController!
    var networkClient: NetworkClient!

    override func setUp() {
        super.setUp()

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let mockTokenHolder = TokenHolder()
        mockTokenHolder.accessToken = "1234"
        let devMenuViewModel = DeveloperMenuViewModel()
        networkClient = NetworkClient(configuration: configuration, authenticationProvider: mockTokenHolder)
        sut = DeveloperMenuViewController(viewModel: devMenuViewModel, networkClient: networkClient)
    }

    override func tearDown() {
        sut = nil
        networkClient = nil

        super.tearDown()
    }

    func test_labelContents() throws {
        XCTAssertEqual(try sut.happyPathButton.title(for: .normal), "Hello World Happy")
        XCTAssertEqual(try sut.unhappyPathButton.title(for: .normal), "Hello World Error")
    }

}

extension DeveloperMenuViewController {
    var happyPathButton: UIButton {
        get throws {
            try XCTUnwrap(view[child: "sts-happy-path-button"])
        }
    }

    var happyPathResultLabel: UILabel {
        get throws {
            try XCTUnwrap(view[child: "sts-happy-path-result"])
        }
    }

    var unhappyPathButton: UIButton {
        get throws {
            try XCTUnwrap(view[child: "sts-unhappy-path-button"])
        }
    }

    var unhappyPathResultLabel: UILabel {
        get throws {
            try XCTUnwrap(view[child: "sts-unhappy-path-result"])
        }
    }
}
