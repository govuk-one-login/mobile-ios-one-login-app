import GDSCommon
import Logging

protocol TabbedViewModel: BaseViewModel {
    var analyticsService: AnalyticsService { get }
    var navigationTitle: GDSLocalisedString { get }
    var sectionModels: [TabbedViewSectionModel] { get }
    var isLoggedIn: Bool { get set }
}

extension TabbedViewModel {
    var numberOfSections: Int {
        sectionModels.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        sectionModels[section].tabModels.count
    }
}
