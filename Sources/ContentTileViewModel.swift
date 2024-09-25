import GDSCommon
import Logging
import UIKit

public struct ContentTileViewModel: GDSContentTileViewModel, GDSContentTileViewModelWithBody, GDSContentTileViewModelWithSecondaryButton {
    public var title: GDSLocalisedString = "app_yourServicesCardTitle"
    public var body: GDSLocalisedString = "app_yourServicesCardBody"
    public var showSeparatorLine: Bool = true
    public var secondaryButtonViewModel: ButtonViewModel
    public var backgroundColour: UIColor? = .systemBackground
    
    init(secondaryButtonViewModel: ButtonViewModel) {
        self.secondaryButtonViewModel = secondaryButtonViewModel
    }
}
