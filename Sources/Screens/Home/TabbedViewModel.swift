import GDSCommon
import UIKit

struct TabbedViewModel: BaseViewModel {
    let rightBarButtonTitle: GDSLocalisedString?
    let backButtonIsHidden: Bool
    
    let navigationTitle: GDSLocalisedString?
    let sectionModels: [TabbedViewSectionModel]
    
    init(rightBarButtonTitle: GDSLocalisedString? = nil,
         backButtonIsHidden: Bool = true,
         title: GDSLocalisedString? = nil,
         sectionModels: [TabbedViewSectionModel] = [TabbedViewSectionModel]()) {
        self.rightBarButtonTitle = rightBarButtonTitle
        self.backButtonIsHidden = backButtonIsHidden
        self.navigationTitle = title
        self.sectionModels = sectionModels
    }
    
    var numberOfSections: Int {
        sectionModels.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        sectionModels[section].tabModels.count
    }
    
    func didAppear() { /* protocol conformance */ }
    
    func didDismiss() { /* protocol conformance */ }
}
