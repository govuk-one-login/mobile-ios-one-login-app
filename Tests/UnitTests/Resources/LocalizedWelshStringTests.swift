// swiftlint:disable line_length

@testable import OneLogin
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
        XCTAssertEqual("app_maybeLaterButton".getWelshString(),
                       "Efallai nes ymlaen")
        XCTAssertEqual("app_enterPasscodeButton".getWelshString(),
                       "Rhowch god mynediad")
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
    }
    
    func test_analyticsScreen_keys() throws {
        XCTAssertEqual("app_acceptAnalyticsPreferences_title".getWelshString(),
                       "Helpu i wella'r ap drwy rannu dadansoddi")
        XCTAssertEqual("acceptAnalyticsPreferences_body".getWelshString(),
                       "Gallwch ein helpu i wella'r ap hwn drwy ddewis i rannu gweithgaredd ap a data dadansoddi yn awtomatig.\n\nMae hyn yn ddewisol ac yn gadael i ni ddeall sut mae pobl yn defnyddio'r gwasanaeth fel ein bod yn gallu ei wella.\n\nGallwch newid eich dewisiadau ar unrhyw bryd yn eich Gosodiadau.")
        XCTAssertEqual("app_privacyNoticeLink".getWelshString(), "Edrych ar hysbysiad preifatrwydd GOV.UK One Login")
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
    
    func test_passcodeInformationScreen_keys() throws {
        XCTAssertEqual("app_noPasscodeSetupTitle".getWelshString(),
                       "Mae'n edrych fel nad oes gan y ffôn hwn god mynediad")
        XCTAssertEqual("app_noPasscodeSetupBody".getWelshString(),
                       "Mae gosod cod mynediad ar eich ffôn yn ychwanegu mwy o ddiogelwch. Yna gallwch fewngofnodi i'r ap y ffordd hyn yn hytrach na gyda'ch cyfeiriad e-bost a'ch cyfrinair.\n\nGallwch osod cod mynediad yn nes ymlaen trwy fynd i'ch gosodiadau ffôn.")
    }
    
    func test_faceIDEnrollmentScreen_keys() throws {
        XCTAssertEqual("app_enableFaceIDTitle".getWelshString(),
                       "Defnyddio Face ID i fewngofnodi")
        XCTAssertEqual("app_enableFaceIDBody".getWelshString(),
                       "Mewngofnodi gyda'ch wyneb yn hytrach na'ch cyfeiriad e-bost a'ch cyfrinair. Nid yw eich Face ID yn cael ei rannu gyda GOV.UK One Login.")
        XCTAssertEqual("app_enableFaceIDFootnote".getWelshString(),
                       "Os ydych yn defnyddio Face ID, gall unrhyw un gyda Face ID wedi'i arbed i'ch ffôn mewngofnoi i'r ap hwn.")
        XCTAssertEqual("app_enableFaceIDButton".getWelshString(),
                       "Defnyddio Face ID")
    }
    
    func test_touchIDEnrollmentScreen_keys() throws {
        XCTAssertEqual("app_enableTouchIDTitle".getWelshString(),
                       "Defnyddio Touch ID i fewngofnodi")
        XCTAssertEqual("app_enableTouchIDBody".getWelshString(),
                       "Mewngofnodi gyda'ch olion bysedd yn hytrach na'ch cyfeiriad e-bost a chyfrinair. Nid yw eich Touch ID yn cael ei rannu â GOV.UK One Login.")
        XCTAssertEqual("app_enableTouchIDFootnote".getWelshString(),
                       "Os ydych yn defnyddio Touch ID, gall unrhyw un gyda Touch ID wedi'i arbed i'ch ffôn mewngofnoi i'r ap hwn.")
        XCTAssertEqual("app_enableTouchIDEnableButton".getWelshString(),
                       "Defnyddio Touch ID")
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
}

// swiftlint:enable line_length
