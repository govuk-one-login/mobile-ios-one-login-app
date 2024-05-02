import Foundation
import GDSCommon

struct TabbedViewSectionFactory {

    @MainActor
    static func homeSections(coordinator: HomeCoordinator) -> [TabbedViewSectionModel] {
#if DEBUG
        let homeSection = createSection(header: "Developer Menu",
                                        footer: nil,
                                        cellModels: [.init(cellTitle: "Developer Menu") {
            coordinator.showDeveloperMenu()
        }])
#else
        let homeSection = TabbedViewSectionModel()
#endif
        return [homeSection]
    }

    static func profileSections(urlOpener: URLOpener) -> [TabbedViewSectionModel] {
        let manageDetailsSection = createSection(header: "app_profileSubtitle1",
                                                 footer: "app_manageSignInDetailsFootnote",
                                                 cellModels: [.init(cellTitle: "app_manageSignInDetailsLink",
                                                                    accessoryView: "arrow.up.right") {
            urlOpener.open(url: AppEnvironment.manageAccountURL)
        }])

        let legalSection = createSection(header: "app_profileSubtitle2",
                                         footer: nil,
                                         cellModels: [.init(cellTitle: "app_privacyNoticeLink2",
                                                            accessoryView: "arrow.up.right") {
            urlOpener.open(url: AppEnvironment.privacyPolicyURL)
        }])

        let helpSection = createSection(header: "app_profileSubtitle3",
                                        footer: nil,
                                        cellModels: [.init(cellTitle: "app_reportAProblemGiveFeedbackLink",
                                                           accessoryView: "arrow.up.right"),
                                                     .init(cellTitle: "app_appGuidanceLink",
                                                           accessoryView: "arrow.up.right")])
        let signoutSection = createSection(header: nil,
                                           footer: nil,
                                           cellModels: [.init(cellTitle: "app_signOutButton",
                                                              textColor: .gdsRed)])

        return [manageDetailsSection,
                legalSection,
                helpSection,
                signoutSection]
    }

    static func createSection(header: GDSLocalisedString?,
                              footer: GDSLocalisedString?,
                              cellModels: [TabbedViewCellModel]) -> TabbedViewSectionModel {

        return TabbedViewSectionModel(sectionTitle: header,
                                      sectionFooter: footer,
                                      tabModels: cellModels)

    }
}
