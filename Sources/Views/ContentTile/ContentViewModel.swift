import GDSCommon
import Logging

protocol ContentViewModel: BaseViewModel {
    var analyticsService: AnalyticsService { get }
    var navigationTitle: GDSLocalisedString { get }
    var sectionModels: [ContentViewSectionModel] { get }
}
