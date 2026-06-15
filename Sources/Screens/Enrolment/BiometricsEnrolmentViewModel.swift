import DesignSystem
import GDSAnalytics
import LocalAuthenticationWrapper
import Logging
import UIKit

struct BiometricsEnrolmentViewModel: GDSCentreAlignedViewModel {
    var screenStyle: GDSScreenStyle
    var body: [any ContentViewModel]
    var movableFooter: [any ContentViewModel]
    var footer: [any ContentViewModel]

    var rightBarButtonTitle: GDSLocalisedString?
    var backButtonTitle: GDSLocalisedString?
    var backButtonIsHidden: Bool

    var didAppear: DesignSystem.Action?
    var didDismiss: DesignSystem.Action?
 
    // swiftlint: disable:next function_body_length
    init(analyticsService: OneLoginAnalyticsService,
         biometricsType: LocalAuthType,
         primaryButtonAction: @escaping () async -> Void,
         secondaryButtonAction: @escaping () -> Void) {
        let analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.localAuth,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        
        let isFaceID = biometricsType == .faceID
        let biometricsTypeString = isFaceID ? "app_FaceID" : "app_TouchID"
        let imageName = isFaceID ? "faceid" : "touchid"
        
        let titleString = GDSLocalisedString(stringKey: "app_enableBiometricsTitle", biometricsTypeString)
        let bodyText = isFaceID ? "app_enableBiometricsFaceIDBody2" : "app_enableBiometricsTouchIDBody2"
        
        let font = UIFont(style: .largeTitle, weight: .thin)
        let configuration = UIImage.SymbolConfiguration(font: font, scale: .large)
        
        let image = UIImage(systemName: imageName, withConfiguration: configuration)
        
        self.init(
            screenStyle: .centred,
            body: [
                GDSImageViewModel(image: image ?? UIImage(),
                                  imageColour: DesignSystem.Color.Text.primary,
                                  contentMode: .scaleAspectFit,
                                  imageFixedHeight: 64,
                                  verticalPadding: .bottom(DesignSystem.Spacing.default)),
                GDSTextViewModel(title: titleString,
                                 titleFont: .largeTitleBold,
                                 alignment: .center,
                                 verticalPadding: .bottom(DesignSystem.Spacing.default)),
                GDSListViewModel(
                    title: GDSLocalisedString(stringKey: "app_enableBiometricsBody1", biometricsTypeString),
                    titleConfig: (font: .body, isHeader: true),
                    items: [
                        GDSLocalisedString(stringKey: "app_enableBiometricsBullet1"),
                        GDSLocalisedString(stringKey: "app_enableBiometricsBullet2")
                    ],
                    style: .bulleted,
                    verticalPadding: .bottom(DesignSystem.Spacing.default)
                ),
                GDSTextViewModel(title: GDSLocalisedString(stringLiteral: bodyText),
                                 alignment: .center,
                                 verticalPadding: .top(.zero))
            ],
            movableFooter: [
                GDSButtonViewModel(title: GDSLocalisedString(stringKey: "app_enableBiometricsButton",
                                                             biometricsTypeString).value,
                                   style: .primary,
                                   buttonAction: .asyncAction({
                                      let event = ButtonEvent(textKey: "app_enableBiometricsButton",
                                                              variableKeys: [biometricsTypeString])
                                       analyticsService.logEvent(event)
                                       
                                       await primaryButtonAction()
                                   }),
                                   verticalPadding: .bottom(DesignSystem.Spacing.default),
                                   horizontalPadding: .horizontal(DesignSystem.Spacing.default)),
                GDSButtonViewModel(title: GDSLocalisedString(stringKey: "app_skipButton").value,
                                   style: .secondary,
                                   buttonAction: .action({
                                       let event = ButtonEvent(textKey: "app_skipButton")
                                       analyticsService.logEvent(event)
                                       
                                       secondaryButtonAction()
                                   }),
                                   verticalPadding: .bottom(DesignSystem.Spacing.default),
                                   horizontalPadding: .horizontal(DesignSystem.Spacing.default))
            ],
            footer: [],
            rightBarButtonTitle: nil,
            backButtonTitle: nil,
            backButtonIsHidden: true,
            didAppear: .action({
                let screenID = isFaceID ?
                    BiometricEnrolmentAnalyticsScreenID.faceIDEnrolment.rawValue :
                    BiometricEnrolmentAnalyticsScreenID.touchIDEnrolment.rawValue
                
                let screenName = isFaceID ?
                BiometricEnrolmentAnalyticsScreen.faceIDEnrolment :
                BiometricEnrolmentAnalyticsScreen.touchIDEnrolment
                
                let screen = ScreenView(id: screenID,
                                        screen: screenName,
                                        titleKey: titleString.stringKey,
                                        variableKeys: [biometricsTypeString])
                analyticsService.trackScreen(screen)
            }),
            didDismiss: nil
        )
    }
    
    init(screenStyle: GDSScreenStyle,
         body: [any ContentViewModel],
         movableFooter: [any ContentViewModel],
         footer: [any ContentViewModel],
         rightBarButtonTitle: GDSLocalisedString?,
         backButtonTitle: GDSLocalisedString?,
         backButtonIsHidden: Bool,
         didAppear: DesignSystem.Action?,
         didDismiss: DesignSystem.Action?) {
        self.screenStyle = screenStyle
        self.body = body
        self.movableFooter = movableFooter
        self.footer = footer
        self.rightBarButtonTitle = rightBarButtonTitle
        self.backButtonTitle = backButtonTitle
        self.backButtonIsHidden = backButtonIsHidden
        self.didAppear = didAppear
        self.didDismiss = didDismiss
    }
}
