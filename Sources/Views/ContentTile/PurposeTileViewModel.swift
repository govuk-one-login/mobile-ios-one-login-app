import GDSCommon
import UIKit

struct PurposeTileViewModel: GDSContentTileViewModel,
                             GDSContentTileViewModelWithBody {
    let title: GDSLocalisedString = "app_appPurposeTileHeader"
    let body: GDSLocalisedString = GDSLocalisedString(stringKey: "app_appPurposeTileBody1",
                                                      "app_nameString")
    let showSeparatorLine: Bool = false
    let backgroundColour: UIColor? = .secondarySystemGroupedBackground
}
