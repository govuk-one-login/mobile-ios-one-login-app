import GDSCommon
import UIKit

struct PurposeTileViewModel: GDSContentTileViewModel,
                             GDSContentTileViewModelWithBody {
    let title: GDSLocalisedString = "app_appPurposeTileHeader"
    let body: GDSLocalisedString = "app_appPurposeTileBody1"
    let showSeparatorLine: Bool = false
    let backgroundColour: UIColor? = .secondarySystemGroupedBackground
}
