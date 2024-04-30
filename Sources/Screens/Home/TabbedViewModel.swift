import GDSCommon
import UIKit

struct TabbedViewModel: BaseViewModel {
    let rightBarButtonTitle: GDSLocalisedString?
    let backButtonIsHidden: Bool
    
    let navigationTitle: GDSLocalisedString?
    let sectionHeaderTitles: [GDSLocalisedString]
    let cellModels: [[TabbedViewCellModel]]
    
    init(rightBarButtonTitle: GDSLocalisedString? = nil,
         backButtonIsHidden: Bool = true,
         title: GDSLocalisedString? = nil,
         sectionHeaderTitles: [GDSLocalisedString] = [GDSLocalisedString](),
         cellModels: [[TabbedViewCellModel]] = [[TabbedViewCellModel]]()) {
        self.rightBarButtonTitle = rightBarButtonTitle
        self.backButtonIsHidden = backButtonIsHidden
        self.navigationTitle = title
        self.sectionHeaderTitles = sectionHeaderTitles
        self.cellModels = cellModels
    }
    
    var numberOfSections: Int {
        sectionHeaderTitles.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        cellModels[section].count
    }
    
    func didAppear() { /* protocol conformance */ }
    
    func didDismiss() { /* protocol conformance */ }
}
