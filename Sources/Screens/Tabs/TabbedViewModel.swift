import GDSCommon
import Logging

@MainActor
protocol TabbedViewModel: BaseViewModel {
    var analyticsService: AnalyticsService { get }
    var navigationTitle: GDSLocalisedString { get }
    var sectionModels: [TabbedViewSectionModel] { get }
}

extension TabbedViewModel {
    var numberOfSections: Int {
        sectionModels.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        sectionModels[section].tabModels.count
    }
}
