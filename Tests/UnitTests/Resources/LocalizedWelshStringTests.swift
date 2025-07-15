// swiftlint:disable line_length

import XCTest

final class LocalizedWelshStringTests: XCTestCase {
    func test_generic_keys() throws {
        XCTAssertEqual("app_closeButton".getWelshString(),
                       "Cau")
        XCTAssertEqual("app_cancelButton".getWelshString(),
                       "Canslo")
        XCTAssertEqual("app_tryAgainButton".getWelshString(),
                       "Ewch yn ôl i roi cynnig eto")
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
        XCTAssertEqual("app_nameString".getWelshString(),
                       "GOV.UK One Login")
    }
    
    func test_localAuthPrompt_keys() throws {
        XCTAssertEqual("app_faceId_subtitle".getWelshString(),
                       "Rhowch god mynediad iPhone")
        XCTAssertEqual("app_touchId_subtitle".getWelshString(),
                       "Datgloi i barhau")
    }
    
    func test_signInScreen_keys() throws {
        XCTAssertEqual("app_signInBody".getWelshString(),
                       "Profwch eich hunaniaeth i gael mynediad at wasanaethau'r llywodraeth.\n\nBydd angen i chi fewngofnodi gyda'ch manylion %@.")
        XCTAssertEqual("app_signInButton".getWelshString(),
                       "Mewngofnodi")
        XCTAssertEqual("app_extendedSignInButton".getWelshString(),
                       "Mewngofnodi gyda %@")
    }
    
    func test_analyticsScreen_keys() throws {
        XCTAssertEqual("app_acceptAnalyticsPreferences_title".getWelshString(),
                       "Helpu i wella'r ap drwy rannu dadansoddi")
        XCTAssertEqual("acceptAnalyticsPreferences_body".getWelshString(),
                       "Gallwch helpu'r tîm %@ i wneud gwelliannau drwy rannu dadansoddeg am sut rydych yn defnyddio'r ap.\n\nGallwch stopio rhannu'r dadansoddeg hyn ar unrhyw amser. Ewch i osodiadau eich ffôn a dewiswch yr ap %@ i weld neu newid eich gosodiadau ap.\n\nGallwch stopio rhannu'r dadansoddiadau hyn ar unrhyw bryd trwy newid gosodiadau eich ap.")
        XCTAssertEqual("app_privacyNoticeLink".getWelshString(), "Darllenwch fwy am hyn yn hysbysiad preifatrwydd %@")
    }
    
    func test_unableToLoginErrorScreen_keys() throws {
        XCTAssertEqual("app_signInErrorTitle".getWelshString(),
                       "Roedd problem wrth eich mewngofnodi")
        XCTAssertEqual("app_signInErrorRecoverableBody".getWelshString(),
                       "Ceisio mewngofnodi eto.")
        XCTAssertEqual("app_signInErrorUnrecoverableBody".getWelshString(),
                       "Rhowch gynnig arall yn nes ymlaen.")
    }
    
    func test_networkConnectionErrorScreen_keys() throws {
        XCTAssertEqual("app_networkErrorTitle".getWelshString(),
                       "Nid ydych wedi'ch cysylltu â'r rhyngrwyd")
        XCTAssertEqual("app_networkErrorBody".getWelshString(),
                       "Mae angen i chi gael cysylltiad rhyngrwyd i ddefnyddio %@.\n\nAilgysylltwch â'r rhyngrwyd a rhoi cynnig eto.")
    }
    
    func test_genericErrorScreen_keys() throws {
        XCTAssertEqual("app_genericErrorPage".getWelshString(),
                       "Mae'n ddrwg gennym, mae yna broblem")
        XCTAssertEqual("app_genericErrorPageBody".getWelshString(),
                       "Rhowch gynnig arall yn nes ymlaen.")
    }
    
    func test_faceIDEnrolmentScreen_keys() throws {
        XCTAssertEqual("app_FaceID".getWelshString(),
                       "Face ID")
        XCTAssertEqual("app_enableFaceIDBody".getWelshString(),
                       "Gallwch ddefnyddio Face ID i ddatgloi'r ap o fewn 30 munud o fewngofnodi gyda %@.\n\nOs ydych yn caniatáu Face ID, bydd unrhyw un sy'n gallu datgloi eich ffôn gyda'u gwyneb neu gyda chod eich ffôn yn gallu cael mynediad i'ch ap.")
        XCTAssertEqual("app_enableBiometricsFaceIDBody2".getWelshString(),
                       "Os ydych yn caniatáu Face ID, bydd unrhyw un sy'n gallu datgloi eich ffôn gyda'u gwyneb neu gyda chod eich ffôn yn gallu cael mynediad i'ch ap.\n\nGallwch droi Face ID i ffwrdd ar gyfer yr ap hwn unrhyw bryd yng ngosodiadau eich ffôn.")
    }
    
    func test_touchIDEnrolmentScreen_keys() throws {
        XCTAssertEqual("app_TouchID".getWelshString(),
                       "Touch ID")
        XCTAssertEqual("app_enableTouchIDBody".getWelshString(),
                       "Gallwch ddefnyddio eich olion bysedd i ddatgloi'r ap o fewn 30 munud o fewngofnodi gyda %@.\n\nOs ydych yn caniatáu Touch ID, bydd unrhyw un sy'n gallu datgloi eich ffôn gyda'u olion bysedd neu gyda chod eich ffôn yn gallu cael mynediad i'ch ap.")
        XCTAssertEqual("app_enableBiometricsTouchIDBody2".getWelshString(),
                       "Os ydych yn caniatáu Touch ID, bydd unrhyw un sy'n gallu datgloi eich ffôn gyda'u olion bysedd neu gyda chod eich ffôn yn gallu cael mynediad i'ch ap.")
    }
    
    func test_biometricsEnrolmentScreen_commonKeys() throws {
        XCTAssertEqual("app_enableLoginBiometricsTitle".getWelshString(),
                       "Datgloi'r ap gyda %@")
        XCTAssertEqual("app_enableBiometricsButton".getWelshString(),
                       "Caniatáu %@")
        XCTAssertEqual("app_enableBiometricsTitle".getWelshString(),
                       "Caniatáu %@")
        XCTAssertEqual("app_enableBiometricsBody1".getWelshString(),
                       "Defnyddiwch %@ i:")
        XCTAssertEqual("app_enableBiometricsBullet1".getWelshString(),
                       "ddatgloi'r ap o fewn 30 munud ar ôl mewngofnodi gyda %@")
        XCTAssertEqual("app_enableBiometricsBullet2".getWelshString(),
                       "gweld ac ychwanegu dogfennau")
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
        XCTAssertEqual("app_tabBarWallet".getWelshString(),
                       "Dogfennau")
    }
    
    func test_settingsScreenKeys() {
        XCTAssertEqual("app_settingsTitle".getWelshString(),
                       "Gosodiadau")
        XCTAssertEqual("app_settingsSignInDetailsTile".getWelshString(),
                       "Eich %@")
        XCTAssertEqual("app_settingsSignInDetailsLink".getWelshString(),
                       "Rheoli eich manylion mewngofnodi")
        XCTAssertEqual("app_settingsSignInDetailsFootnote".getWelshString(),
                       "Efallai y bydd angen i chi fewngofnodi eto i reoli eich manylion %@.")
        XCTAssertEqual("app_privacyNoticeLink2".getWelshString(),
                       "Rhybudd Preifatrwydd %@")
        XCTAssertEqual("app_settingsSubtitle1".getWelshString(),
                       "Help ac adborth")
        XCTAssertEqual("app_contactLink".getWelshString(),
                       "Cysylltu %@")
        XCTAssertEqual("app_appGuidanceLink".getWelshString(),
                       "Defnyddio'r ap %@")
        XCTAssertEqual("app_signOutButton".getWelshString(),
                       "Allgofnodi")
        XCTAssertEqual("app_settingsSubtitle2".getWelshString(),
                       "Am yr ap")
        XCTAssertEqual("app_settingsAnalyticsToggle".getWelshString(),
                       "Rhannu dadansoddeg yr ap")
        XCTAssertEqual("app_settingsAnalyticsToggleFootnote".getWelshString(),
                       "Gallwch rannu dadansoddeg anhysbys am sut rydych yn defnyddio'r ap i helpu'r tîm %@ i wneud gwelliannau. Darllenwch fwy yn yr hysbysiad preifatrwydd %@.")
        XCTAssertEqual("app_accessibilityStatement".getWelshString(),
                       "Datganiad hygyrchedd")
    }
    
    func test_signOutPageKeys() {
        XCTAssertEqual("app_signOutConfirmationTitle".getWelshString(),
                       "Ydych chi'n siwr eich bod chi eisiau allgofnodi?")
        XCTAssertEqual("app_signOutConfirmationBody1".getWelshString(),
                       "Os byddwch yn allgofnodi, bydd y wybodaeth a gedwir yn eich ap yn cael ei dileu. Mae hyn er mwyn lleihau'r risg y bydd rhywun arall yn gweld eich gwybodaeth.")
        XCTAssertEqual("app_signOutConfirmationBody2".getWelshString(),
                       "Mae hyn yn golygu:")
        XCTAssertEqual("app_signOutConfirmationBullet1".getWelshString(),
                       "bydd unrhyw ddogfennau yn eich ap yn cael eu dileu")
        XCTAssertEqual("app_signOutConfirmationBullet2".getWelshString(),
                       "os ydych yn defnyddio Face ID neu Touch ID i ddatgloi'r ap, bydd hyn yn cael ei ddiffodd")
        XCTAssertEqual("app_signOutConfirmationBullet3".getWelshString(),
                       "byddwch yn stopio rhannu dadansoddeg am sut rydych yn defnyddio'r ap")
        XCTAssertEqual("app_signOutConfirmationBody3".getWelshString(),
                       "Y tro nesaf y byddwch yn mewngofnodi, byddwch yn gallu ychwanegu eich dogfennau eto ac ailosod eich dewisiadau.")
        XCTAssertEqual("app_signOutAndDeleteAppDataButton".getWelshString(),
                       "Mewngofnodi a dileu gwybodaeth")
    }
    
    func test_signOutSuccessfulPageKeys() {
        XCTAssertEqual("app_signedOutTitle".getWelshString(),
                       "Rydych wedi allfognodi")
        XCTAssertEqual("app_signedOutBodyWithWallet".getWelshString(),
                       "Er mwyn cadw'ch gwybodaeth yn ddiogel, mae unrhyw ddogfennau yn yr ap hwn wedi'u dileu ac mae eich dewisiadau wedi'u hailosod.\n\nMae angen i chi fewngofnodi ac ailosod eich dewisiadau i barhau i ddefnyddio'r ap. Yna byddwch yn gallu ychwanegu eich dogfennau eto.")
        XCTAssertEqual("app_signedOutBodyNoWallet".getWelshString(),
                       "Er mwyn cadw'ch gwybodaeth yn ddiogel, mae eich dewisiadau ap wedi'u hailosod.\n\nMae angen i chi fewngofnodi a gosod eich dewisiadau eto i barhau i ddefnyddio'r ap.")
    }
    
    func test_signOutErrorPageKeys() {
        XCTAssertEqual("app_signOutErrorTitle".getWelshString(),
                       "Roedd problem wrth eich allgofnodi")
        XCTAssertEqual("app_signOutErrorBody".getWelshString(),
                       "Gallwch orfodi allgofnodi trwy ddileu'r ap o'ch dyfais.")
    }
    
    func test_signOutWarningPageKeys() {
        XCTAssertEqual("app_signOutWarningTitle".getWelshString(),
                       "Mae angen i chi fewngofnodi eto")
        XCTAssertEqual("app_signOutWarningBody".getWelshString(),
                       "Mae mwy na 30 munud wedi mynd heibio ers i chi fewngofnodi ddiwethaf i ap %@.\n\nMewngofnodwch eto i barhau.")
    }
    
    func test_dataDeletedWarningPageKeys() {
        XCTAssertEqual("app_dataDeletionWarningTitle".getWelshString(),
                       "Mae rhywbeth wedi mynd o'i le")
        
        XCTAssertEqual("app_dataDeletionWarningBody".getWelshString(),
                       "Ni allem gadarnhau eich manylion mewngofnodi.\n\nEr mwyn cadw eich gwybodaeth yn ddiogel, mae unrhyw ddogfennau yn eich ap wedi cael eu dileu ac mae eich dewisiadau wedi cael eu hailosod.\n\nMae angen i chi fewngofnodi ac ailosod eich dewisiadau i barhau i ddefnyddio'r ap. Yna byddwch yn gallu ychwanegu eich dogfennau eto.")
        
        XCTAssertEqual("app_dataDeletionWarningBodyNoWallet".getWelshString(),
                       "Nid oeddem yn gallu cadarnhau eich manylion mewngofnodi.\n\nEr mwyn cadw'ch gwybodaeth yn ddiogel, mae eich dewis o ddefnyddio Touch ID neu Face ID i ddatgloi'r ap wedi'i ailosod.\n\nMae angen i chi fewngofnodi a gosod eich dewisiadau eto i barhau i ddefnyddio'r ap.")
    }

    func test_updateAppPageKeys() {
        XCTAssertEqual("app_updateAppTitle".getWelshString(),
                       "Mae angen i chi ddiweddaru eich ap")
        XCTAssertEqual("app_updateAppBody".getWelshString(),
                       "Rydych yn defnyddio hen fersiwn o'r ap %@.\n\nDiweddarwch eich ap i barhau.")
        XCTAssertEqual("app_updateAppButton".getWelshString(),
                       "Diweddaru Ap %@")
    }
    
    func test_homeTileKeys() {
        XCTAssertEqual("app_welcomeTileHeader".getWelshString(),
                       "Croeso")
        XCTAssertEqual("app_welcomeTileBody1".getWelshString(),
                       "Gallwch ddefnyddio'r ap hwn i brofi eich hunaniaeth i gael mynediad at rai gwasanaethau'r llywodraeth.")
        XCTAssertEqual("app_appPurposeTileHeader".getWelshString(),
                       "Sut i brofi eich hunaniaeth")
        XCTAssertEqual("app_appPurposeTileBody1".getWelshString(),
                       "Os oes angen i chi brofi eich hunaniaeth gyda %@ i gael mynediad at wasanaeth, gofynnir i chi agor yr ap hwn. Mae'n gweithio trwy baru eich wyneb â'ch ID gyda llun.")
    }
    
    func test_appUnavailablePageKeys() {
        XCTAssertEqual("app_appUnavailableTitle".getWelshString(),
                       "Mae'n ddrwg gennym, nid yw'r ap ar gael")
        XCTAssertEqual("app_appUnavailableBody".getWelshString(),
                       "Ni allwch ddefnyddio'r ap %@ ar hyn o bryd.\n\nRhowch gynnig arall yn nes ymlaen.")
    }
    
    func test_accessibilityHintKeys() {
        XCTAssertEqual("app_externalBrowser".getWelshString(), "Agor mewn porwr gwe")
        XCTAssertEqual("app_externalApp".getWelshString(), "Yn agor yn yr App Store")
        XCTAssertEqual("app_loadingLabel".getWelshString(), "Llwytho %@")
    }
    
    func test_localAuthSettingsError_keys() throws {
        XCTAssertEqual("app_localAuthManagerErrorTitle".getWelshString(),
                       "Mae angen i chi ddiweddaru gosodiadau eich ffôn")
        XCTAssertEqual("app_localAuthManagerErrorBody1".getWelshString(),
                       "I ychwanegu dogfennau, mae angen i chi ddiogelu eich ffôn gyda chod mynediad.\n\nMae hyn er mwyn sicrhau na all unrhyw un arall weld na hychwanegu dogfennau at eich ap.")
        XCTAssertEqual("app_localAuthManagerErrorBody3".getWelshString(),
                       "Mae angen i chi:")
        XCTAssertEqual("app_localAuthManagerErrorNumberedList1FaceID".getWelshString(),
                       "Fynd i Face ID & Passcode yng ngosodiadau eich ffôn.")
        XCTAssertEqual("app_localAuthManagerErrorNumberedList1TouchID".getWelshString(),
                       "Fynd i Touch ID & Passcode yng ngosodiadau eich ffôn.")
        XCTAssertEqual("app_localAuthManagerErrorNumberedList2".getWelshString(),
                       "Gwasgu Turn Passcode On a dilyn y cyfarwyddiadau.")
        XCTAssertEqual("app_localAuthManagerErrorNumberedList3".getWelshString(),
                       "Dewch yn ôl i barhau i ddefnyddio eich dogfennau.")
        XCTAssertEqual("app_localAuthManagerErrorGoToSettingsButton".getWelshString(),
                       "Ewch i osodiadau ffôn")
    }
    
    func test_localAuthBiometricsError_keys() throws {
        XCTAssertEqual("app_localAuthManagerBiometricsErrorTitle".getWelshString(),
                       "Mae angen i chi ganiatáu %@")
        XCTAssertEqual("app_localAuthManagerBiometricsFaceIDErrorBody".getWelshString(),
                       "I ychwanegu dogfennau at eich GOV.UK Wallet, mae angen i chi ganiatáu Face ID. Mae hyn er mwyn cadw'ch dogfennau'n ddiogel.\n\nPan fyddwch yn caniatáu Face ID, bydd unrhyw un sy'n gallu datgloi eich ffôn gyda'u gwyneb neu gyda chod eich ffôn yn gallu cael mynediad i'ch ap.\n\nGallwch droi Face ID i ffwrdd ar gyfer yr ap hwn unrhyw bryd yng ngosodiadau eich ffôn.")
        XCTAssertEqual("app_localAuthManagerBiometricsTouchIDErrorBody".getWelshString(),
                       "I ychwanegu dogfennau at eich GOV.UK Wallet, mae angen i chi ganiatáu Touch ID. Mae hyn er mwyn cadw'ch dogfennau'n ddiogel.\n\nPan fyddwch yn caniatáu Touch ID, bydd unrhyw un sy'n gallu datgloi eich ffôn gyda'u olion bysedd neu gyda chod eich ffôn yn gallu cael mynediad i'ch ap.")
    }
}

// swiftlint:enable line_length
