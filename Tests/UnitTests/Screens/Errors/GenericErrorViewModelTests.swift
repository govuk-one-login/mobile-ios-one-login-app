import GDSAnalytics
@testable import OneLogin
import Testing

final class Listener {
    private(set) var didCall: Bool = false

    func callAsFunction() {
        didCall = true
    }
}

@MainActor
struct GenericErrorViewModelTests {
    let sut: GenericErrorViewModel

    let mockAnalyticsService = MockAnalyticsService()
    let buttonActionListener: Listener

    var didCallButtonAction: Bool {
        buttonActionListener.didCall
    }

    init() {
        let buttonActionListener = Listener()
        self.buttonActionListener = buttonActionListener

        sut = GenericErrorViewModel(analyticsService: mockAnalyticsService,
                                    errorDescription: "error description") {
            buttonActionListener()
        }
    }
}

extension GenericErrorViewModelTests {
    @Test("""
          Check that the label contents are assigned correctly by the initialiser
          """)
    func test_page() {
        #expect(sut.image == .error)
        #expect(sut.title.stringKey == "app_genericErrorPage")
        #expect(sut.bodyContent.count == 1)
        #expect(sut.errorDescription == "error description")
        #expect(sut.rightBarButtonTitle == nil)
        #expect(sut.backButtonIsHidden)
    }

    @Test("""
          Validates that the button action:
            - calls the injected closure
            - logs the `Link` analytics event
          """)
    func test_button() {
        #expect(sut.buttonViewModels[0].title.stringKey == "app_tryAgainButton")
        #expect(!didCallButtonAction)
        #expect(mockAnalyticsService.eventsLogged.count == 0)
        sut.buttonViewModels[0].action()
        #expect(didCallButtonAction)
        #expect(mockAnalyticsService.eventsLogged.count == 1)
        let event = LinkEvent(textKey: "app_tryAgainButton",
                              linkDomain: AppEnvironment.mobileBaseURLString,
                              external: .false)
        #expect(mockAnalyticsService.eventsLogged == [event.name.name])
        #expect(mockAnalyticsService.eventsParamsLogged == event.parameters)
    }

    @Test("""
          Validates that did appear logs the expected analytics event
          """)
    func test_didAppear() {
        #expect(mockAnalyticsService.screenViews.count == 0)
        sut.didAppear()
        #expect(mockAnalyticsService.screenViews.count == 1)
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.generic.rawValue,
                                     screen: ErrorAnalyticsScreen.generic,
                                     titleKey: "app_genericErrorPage",
                                     reason: sut.errorDescription)
        #expect(mockAnalyticsService.screenViews as? [ErrorScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
}
