import GDSCommon
import UIKit

struct WelcomeTileViewModel: GDSContentTileViewModel,
                             GDSContentTileViewModelWithBody {
    let title: GDSLocalisedString = "app_welcomeTileHeader"
    let body: GDSLocalisedString = "app_welcomeTileBody1"
    let showSeparatorLine: Bool = false
    let backgroundColour: UIColor? = .secondarySystemGroupedBackground
}
