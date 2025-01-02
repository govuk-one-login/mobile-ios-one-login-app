// swiftlint:disable line_length

import XCTest

final class LocalizedWelshStringTests: XCTestCase {
    func test_generic_keys() throws {
        XCTAssertEqual("app_closeButton".getWelshString(),
                       "Cau")
        XCTAssertEqual("app_cancelButton".getWelshString(),
                       "Canslo")
        XCTAssertEqual("app_tryAgainButton".getWelshString(),
                       "Rhowch gynnig arall")
        XCTAssertEqual("app_continueButton".getWelshString(),
                       "Parhau")
        XCTAssertEqual("app_agreeButton".getWelshString(),
                       "Cytuno")
        XCTAssertEqual("app_disagreeButton".getWelshString(),
                       "Anghytuno")
        XCTAssertEqual("app_loadingBody".getWelshString(),
                       "Llwytho")
        XCTAssertEqual("app_skipButton".getWelshString(),
                       "Osgoi")
        XCTAssertEqual("app_enterPasscodeButton".getWelshString(),
                       "Rhowch god mynediad")
        XCTAssertEqual("app_exitButton".getWelshString(),
                       "Gadael")
    }
    
    func test_localAuthPrompt_keys() throws {
        XCTAssertEqual("app_faceId_subtitle".getWelshString(),
                       "Rhowch god mynediad iPhone")
        XCTAssertEqual("app_touchId_subtitle".getWelshString(),
                       "Datgloi i barhau")
    }
    
    func test_signInScreen_keys() throws {
        XCTAssertEqual("app_signInTitle".getWelshString(),
                       "GOV.UK One Login")
        XCTAssertEqual("app_signInBody".getWelshString(),
                       "Mewngofnodwch gyda'r cyfeiriad e-bost rydych yn ei ddefnyddio ar gyfer eich GOV.UK One Login.")
        XCTAssertEqual("app_signInButton".getWelshString(),
                       "Mewngofnodi")
        XCTAssertEqual("app_extendedSignInButton".getWelshString(),
                       "Mewngofnodi gyda GOV.UK One Login")
    }
    
    func test_analyticsScreen_keys() throws {
        XCTAssertEqual("app_acceptAnalyticsPreferences_title".getWelshString(),
                       "Helpu i wella'r ap drwy rannu dadansoddi")
        XCTAssertEqual("acceptAnalyticsPreferences_body".getWelshString(),
                       "Gallwch helpu'r tîm GOV.UK One Login i wneud gwelliannau drwy rannu dadansoddeg am sut rydych yn defnyddio'r ap.\n\nGallwch stopio rhannu'r dadansoddeg hyn ar unrhyw amser. Ewch i osodiadau eich ffôn a dewiswch yr ap GOV.UK One Login i weld neu newid eich gosodiadau ap.\n\nGallwch stopio rhannu'r dadansoddiadau hyn ar unrhyw bryd trwy newid gosodiadau eich ap.")
        XCTAssertEqual("app_privacyNoticeLink".getWelshString(), "Darllenwch fwy am hyn yn hysbysiad preifatrwydd GOV.UK One Login")
    }
    
    func test_unableToLoginErrorScreen_keys() throws {
        XCTAssertEqual("app_signInErrorTitle".getWelshString(),
                       "Roedd problem wrth eich mewngofnodi")
        XCTAssertEqual("app_signInErrorBody".getWelshString(),
                       "Gallwch geisio mewngofnodi eto.\n\nOs na fydd hyn yn gweithio, efallai y bydd angen i chi roi cynnig arall yn nes ymlaen.")
    }
    
    func test_networkConnectionErrorScreen_keys() throws {
        XCTAssertEqual("app_networkErrorTitle".getWelshString(),
                       "Mae'n ymddangos nad ydych ar-lein")
        XCTAssertEqual("app_networkErrorBody".getWelshString(),
                       "Nid yw GOV.UK One Login ar gael os nad ydych ar-lein. Ailgysylltwch â'r rhyngrwyd a rhoi cynnig arall.")
    }
    
    func test_genericErrorScreen_keys() throws {
        XCTAssertEqual("app_somethingWentWrongErrorTitle".getWelshString(),
                       "Aeth rhywbeth o'i le")
        XCTAssertEqual("app_somethingWentWrongErrorBody".getWelshString(),
                       "Rhowch gynnig arall yn nes ymlaen.")
    }
    
    func test_faceIDEnrolmentScreen_keys() throws {
        XCTAssertEqual("app_enableFaceIDTitle".getWelshString(),
                       "Datgloi'r ap gyda Face ID")
        XCTAssertEqual("app_enableFaceIDBody".getWelshString(),
                       "Gallwch ddefnyddio Face ID i ddatgloi'r ap o fewn 30 munud o fewngofnodi gyda GOV.UK One Login.\n\nOs ydych yn caniatáu Face ID, bydd unrhyw un sy'n gallu datgloi eich ffôn gyda'u gwyneb neu gyda chod eich ffôn yn gallu cael mynediad i'ch ap.")
        XCTAssertEqual("app_enableFaceIDButton".getWelshString(),
                       "Caniatáu Face ID")
    }
    
    func test_touchIDEnrolmentScreen_keys() throws {
        XCTAssertEqual("app_enableTouchIDTitle".getWelshString(),
                       "Datgloi'r ap gyda Touch ID")
        XCTAssertEqual("app_enableTouchIDBody".getWelshString(),
                       "Gallwch ddefnyddio eich olion bysedd i ddatgloi'r ap o fewn 30 munud o fewngofnodi gyda GOV.UK One Login.\n\nOs ydych yn caniatáu Touch ID, bydd unrhyw un sy'n gallu datgloi eich ffôn gyda'u olion bysedd neu gyda chod eich ffôn yn gallu cael mynediad i'ch ap.")
        XCTAssertEqual("app_enableTouchIDEnableButton".getWelshString(),
                       "Caniatáu Touch ID")
    }
    
    func test_unlockScreenKeys() {
        XCTAssertEqual("app_unlockButton".getWelshString(),
                       "Datgloi")
    }
    
    func test_homeScreenKeys() {
        XCTAssertEqual("app_homeTitle".getWelshString(),
                       "Hafan")
        XCTAssertEqual("app_displayEmail".getWelshString(),
                       "Rydych wedi mewngofnodi fel\n%@")
    }
    
    func test_walletScreenKeys() {
        XCTAssertEqual("app_walletTitle".getWelshString(),
                       "Waled")
    }
    
    func test_profileScreenKeys() {
        XCTAssertEqual("app_profileTitle".getWelshString(),
                       "Proffil")
        XCTAssertEqual("app_profileSubtitle1".getWelshString(),
                       "Eich manylion")
        XCTAssertEqual("app_manageSignInDetailsLink".getWelshString(),
                       "Rheoli manylion mewngofnodi")
        XCTAssertEqual("app_manageSignInDetailsFootnote".getWelshString(),
                       "Rheoli eich manylion mewngofnodi gyda'r gwasanaeth gwe GOV.UK One Login. Bydd angen i chi fewngofnodi eto.")
        XCTAssertEqual("app_signInDetails".getWelshString(),
                       "Manylion mewngofnodi")
        XCTAssertEqual("app_profileSubtitle2".getWelshString(),
                       "Cyfreithiol")
        XCTAssertEqual("app_privacyNoticeLink2".getWelshString(),
                       "Rhybudd Preifatrwydd GOV.UK One Login")
        XCTAssertEqual("app_profileSubtitle3".getWelshString(),
                       "Help ac adborth")
        XCTAssertEqual("app_reportAProblemGiveFeedbackLink".getWelshString(),
                       "Rhoi gwybod am broblem neu roi adborth")
        XCTAssertEqual("app_appGuidanceLink".getWelshString(),
                       "Canllawiau ar ddefnyddio'r ap")
        XCTAssertEqual("app_signOutButton".getWelshString(),
                       "Allgofnodi")
    }
    
    func test_signOutPageKeys() {
        XCTAssertEqual("app_signOutConfirmationTitle".getWelshString(),
                       "Bydd allgofnodi yn dileu data eich ap")
        XCTAssertEqual("app_signOutConfirmationBody1".getWelshString(),
                       "Pan fyddwch yn allgofnodi, bydd yr holl wybodaeth a dogfennau a gedwir yn eich ap yn cael eu dileu, gan gynnwys:")
        XCTAssertEqual("app_signOutConfirmationBullet1".getWelshString(),
                       "unrhyw ddogfennau a arbedwyd yn eich GOV.UK Wallet")
        XCTAssertEqual("app_signOutConfirmationBullet2".getWelshString(),
                       "eich gosodiadau ar gyfer mewngofnodi")
        XCTAssertEqual("app_signOutConfirmationBullet3".getWelshString(),
                       "eich dewisiadau rhannu dadansoddi")
        XCTAssertEqual("app_signOutConfirmationBody2".getWelshString(),
                       "Mae hyn er mwyn cadw'ch gwybodaeth yn ddiogel.")
        XCTAssertEqual("app_signOutConfirmationBody3".getWelshString(),
                       "Bydd unrhyw ddogfennau sydd wedi'u dileu yn dal i fod ar gael ar-lein i chi eu hychwanegu at eich GOV.UK Wallet eto.")
        XCTAssertEqual("app_signOutAndDeleteAppDataButton".getWelshString(),
                       "Allgofnodwch a dileu data yr ap")
    }
    
    func test_signOutErrorPageKeys() {
        XCTAssertEqual("app_signOutErrorTitle".getWelshString(),
                       "Roedd problem wrth eich allgofnodi")
        XCTAssertEqual("app_signOutErrorBody".getWelshString(),
                       "Gallwch orfodi allgofnodi trwy ddileu'r ap o'ch dyfais.")
    }
    
    func test_signOutWarningPageKeys() {
        XCTAssertEqual("app_signOutWarningTitle".getWelshString(),
                       "Rydych wedi cael eich allgofnodi")
        XCTAssertEqual("app_signOutWarningBody".getWelshString(),
                       "Mae hyn er mwyn cadw'r wybodaeth yn eich ap GOV.UK One Login yn ddiogel.\n\nMae angen i chi fewngofnodi eto i barhau.")
    }
    
    func test_dataDeletedWarningPageKeys() {
        XCTAssertEqual("app_dataDeletionWarningBody".getWelshString(),
                       "Rydym wedi dileu'r wybodaeth yn eich ap GOV.UK One Login oherwydd ni allwn gadarnhau eich manylion mewngofnodi.\n\nRydym wedi gwneud hyn i leihau'r risg y bydd rhywun arall yn gweld eich gwybodaeth.\n\nEr mwyn parhau i ddefnyddio'r ap, bydd angen i chi fewngofnodi. Yna gofynnir i chi osod eich dewisiadau dadansoddi a mewngofnodi eto.")
    }

    func test_updateAppPageKeys() {
        XCTAssertEqual("app_updateAppTitle".getWelshString(),
                       "Mae angen i chi ddiweddaru eich ap")
        XCTAssertEqual("app_updateAppBody".getWelshString(),
                       "Rydych yn defnyddio hen fersiwn o'r ap GOV.UK One Login.\n\nDiweddarwch eich ap i barhau.")
        XCTAssertEqual("app_updateAppButton".getWelshString(),
                       "Diweddaru Ap GOV.UK One Login")
    }
    
    func test_yourServiceTile() {
        XCTAssertEqual("app_yourServicesCardTitle".getWelshString(),
                       "Eich gwasanaethau")
        XCTAssertEqual("app_yourServicesCardBody".getWelshString(),
                       "Gweld a chael mynediad at y gwasanaethau rydych wedi'u defnyddio gyda GOV.UK One Login")
        XCTAssertEqual("app_yourServicesCardLink".getWelshString(),
                       "Ewch i'ch gwasanaethau")
    }
    
    func test_appUnavailablePageKeys() {
        XCTAssertEqual("app_appUnavailableTitle".getWelshString(),
                       "Mae'n ddrwg gennym, nid yw'r ap ar gael")
        XCTAssertEqual("app_appUnavailableBody".getWelshString(),
                       "Ni allwch ddefnyddio'r ap GOV.UK One Login ar hyn o bryd.\n\nRhowch gynnig arall yn nes ymlaen.")
    }
}

// swiftlint:enable line_length
