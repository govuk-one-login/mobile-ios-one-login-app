// swiftlint:disable line_length

import Testing

// swiftlint:disable type_body_length
struct LocalizedWelshStringTests {
    @Test
    func test_generic_keys() {
        #expect("app_closeButton".getWelshString() ==
                       "Cau")
        #expect("app_cancelButton".getWelshString() ==
                       "Canslo")
        #expect("app_doneButton".getWelshString() ==
                       "Wedi'i wneud")
        #expect("app_tryAgainButton".getWelshString() ==
                       "Ewch yn ôl i roi cynnig eto")
        #expect("app_continueButton".getWelshString() ==
                       "Parhau")
        #expect("app_agreeButton".getWelshString() ==
                       "Cytuno")
        #expect("app_disagreeButton".getWelshString() ==
                       "Anghytuno")
        #expect("app_loadingBody".getWelshString() ==
                       "Llwytho")
        #expect("app_skipButton".getWelshString() ==
                       "Osgoi")
        #expect("app_enterPasscodeButton".getWelshString() ==
                       "Rhowch god mynediad")
        #expect("app_exitButton".getWelshString() ==
                       "Gadael")
        #expect("app_nameString".getWelshString() ==
                       "GOV.UK One Login")
    }
    
    @Test
    func test_localAuthPrompt_keys() {
        #expect("app_faceId_subtitle".getWelshString() ==
                       "Rhowch god mynediad iPhone")
        #expect("app_touchId_subtitle".getWelshString() ==
                       "Datgloi i barhau")
    }
    
    @Test
    func test_signInScreen_keys() {
        #expect("app_signInBody".getWelshString() ==
                       "Profwch eich hunaniaeth i gael mynediad at wasanaethau'r llywodraeth.\n\nBydd angen i chi fewngofnodi gyda'ch manylion %@.")
        #expect("app_signInButton".getWelshString() ==
                       "Mewngofnodi")
        #expect("app_extendedSignInButton".getWelshString() ==
                       "Mewngofnodi gyda %@")
    }
    
    @Test
    func test_analyticsScreen_keys() {
        #expect("app_acceptAnalyticsPreferences_title".getWelshString() ==
                       "Helpu i wella'r ap drwy rannu dadansoddi")
        #expect("acceptAnalyticsPreferences_body".getWelshString() ==
                       "Gallwch helpu'r tîm %@ i wneud gwelliannau drwy rannu dadansoddeg am sut rydych yn defnyddio'r ap.\n\nGallwch stopio rhannu'r dadansoddeg hyn ar unrhyw amser. Ewch i osodiadau eich ffôn a dewiswch yr ap %@ i weld neu newid eich gosodiadau ap.\n\nGallwch stopio rhannu'r dadansoddiadau hyn ar unrhyw bryd trwy newid gosodiadau eich ap.")
        #expect("app_privacyNoticeLink".getWelshString() == "Darllenwch fwy am hyn yn hysbysiad preifatrwydd %@")
    }
    
    @Test
    func test_unableToLoginErrorScreen_keys() {
        #expect("app_signInErrorTitle".getWelshString() ==
                       "Roedd problem wrth eich mewngofnodi")
        #expect("app_signInErrorRecoverableBody".getWelshString() ==
                       "Ceisio mewngofnodi eto.")
        #expect("app_signInErrorUnrecoverableBody".getWelshString() ==
                       "Rhowch gynnig arall yn nes ymlaen.")
    }
    
    @Test
    func test_networkConnectionErrorScreen_keys() {
        #expect("app_networkErrorTitle".getWelshString() ==
                       "Nid ydych wedi'ch cysylltu â'r rhyngrwyd")
        #expect("app_networkErrorBody".getWelshString() ==
                       "Mae angen i chi gael cysylltiad rhyngrwyd i ddefnyddio %@.\n\nAilgysylltwch â'r rhyngrwyd a rhoi cynnig eto.")
    }
    
    @Test
    func test_genericErrorScreen_keys() {
        #expect("app_genericErrorPage".getWelshString() ==
                       "Mae'n ddrwg gennym, mae problem")
        #expect("app_genericErrorPageBody".getWelshString() ==
                       "Rhowch gynnig arall yn nes ymlaen.")
    }
    
    @Test
    func test_faceIDEnrolmentScreen_keys() {
        #expect("app_FaceID".getWelshString() ==
                       "Face ID")
        #expect("app_enableBiometricsFaceIDBody2".getWelshString() ==
                       "Os ydych yn caniatáu Face ID, bydd unrhyw un sy'n gallu datgloi eich ffôn gyda'u gwyneb neu gyda chod eich ffôn yn gallu cael mynediad i'ch ap.\n\nGallwch droi Face ID i ffwrdd ar gyfer yr ap hwn unrhyw bryd yng ngosodiadau eich ffôn.")
    }
    
    @Test
    func test_touchIDEnrolmentScreen_keys() {
        #expect("app_TouchID".getWelshString() ==
                       "Touch ID")
        #expect("app_enableBiometricsTouchIDBody2".getWelshString() ==
                       "Os ydych yn caniatáu Touch ID, bydd unrhyw un sy'n gallu datgloi eich ffôn gyda'u olion bysedd neu gyda chod eich ffôn yn gallu cael mynediad i'ch ap.")
    }
    
    @Test
    func test_biometricsEnrolmentScreen_commonKeys() {
        #expect("app_enableBiometricsButton".getWelshString() ==
                       "Caniatáu %@")
        #expect("app_enableBiometricsTitle".getWelshString() ==
                       "Caniatáu %@")
        #expect("app_enableBiometricsBody1".getWelshString() ==
                       "Defnyddiwch %@ i:")
        #expect("app_enableBiometricsBullet1".getWelshString() ==
                       "mewngofnodi")
        #expect("app_enableBiometricsBullet2".getWelshString() ==
                       "gweld ac ychwanegu dogfennau")
    }
    
    @Test
    func test_unlockScreenKeys() {
        #expect("app_unlockButton".getWelshString() ==
                       "Datgloi")
    }
    
    @Test
    func test_homeScreenKeys() {
        #expect("app_homeTitle".getWelshString() ==
                       "Hafan")
        #expect("app_displayEmail".getWelshString() ==
                       "Rydych wedi mewngofnodi fel\n%@")
    }
    
    @Test
    func test_walletScreenKeys() {
        #expect("app_tabBarWallet".getWelshString() ==
                       "Dogfennau")
    }
    
    @Test
    func test_settingsScreenKeys() {
        #expect("app_settingsTitle".getWelshString() ==
                       "Gosodiadau")
        #expect("app_settingsSignInDetailsTile".getWelshString() ==
                       "Eich %@")
        #expect("app_settingsSignInDetailsLink".getWelshString() ==
                       "Rheoli eich manylion mewngofnodi")
        #expect("app_settingsSignInDetailsFootnote".getWelshString() ==
                       "Efallai y bydd angen i chi fewngofnodi eto i reoli eich manylion %@.")
        #expect("app_privacyNoticeLink2".getWelshString() ==
                       "Rhybudd Preifatrwydd %@")
        #expect("app_settingsSubtitle1".getWelshString() ==
                       "Help ac adborth")
        #expect("app_contactLink".getWelshString() ==
                       "Cysylltu %@")
        #expect("app_appGuidanceLink".getWelshString() ==
                       "Defnyddio'r ap %@")
        #expect("app_proveYourIdentityLink".getWelshString() ==
                       "Profi eich hunaniaeth")
        #expect("app_addDocumentsLink".getWelshString() ==
                       "Ychwanegu dogfennau at eich ap")
        #expect("app_signOutButton".getWelshString() ==
                       "Allgofnodi")
        #expect("app_settingsSubtitle2".getWelshString() ==
                       "Am yr ap")
        #expect("app_settingsAnalyticsToggle".getWelshString() ==
                       "Rhannu dadansoddeg yr ap")
        #expect("app_settingsAnalyticsToggleFootnote".getWelshString() ==
                       "Gallwch rannu dadansoddeg anhysbys am sut rydych yn defnyddio'r ap i helpu'r tîm %@ i wneud gwelliannau. Darllenwch fwy yn yr hysbysiad preifatrwydd %@.")
        #expect("app_accessibilityStatement".getWelshString() ==
                       "Datganiad hygyrchedd")
        #expect("app_termsAndConditionsLink".getWelshString() ==
                       "Telerau ac amodau")
    }
    
    @Test
    func test_signOutPageKeys() {
        #expect("app_signOutConfirmationTitle".getWelshString() ==
                       "Ydych chi'n siwr eich bod chi eisiau allgofnodi?")
        #expect("app_signOutConfirmationBody1".getWelshString() ==
                       "Os byddwch yn allgofnodi, bydd y wybodaeth a gedwir yn eich ap yn cael ei dileu. Mae hyn er mwyn lleihau'r risg y bydd rhywun arall yn gweld eich gwybodaeth.")
        #expect("app_signOutConfirmationBody2".getWelshString() ==
                       "Mae hyn yn golygu:")
        #expect("app_signOutConfirmationBullet1".getWelshString() ==
                       "bydd unrhyw ddogfennau yn eich ap yn cael eu dileu")
        #expect("app_signOutConfirmationBullet2".getWelshString() ==
                       "os ydych yn defnyddio Face ID neu Touch ID i ddatgloi'r ap, bydd hyn yn cael ei ddiffodd")
        #expect("app_signOutConfirmationBullet3".getWelshString() ==
                       "byddwch yn stopio rhannu dadansoddeg am sut rydych yn defnyddio'r ap")
        #expect("app_signOutConfirmationBody3".getWelshString() ==
                       "Y tro nesaf y byddwch yn mewngofnodi, byddwch yn gallu ychwanegu eich dogfennau eto ac ailosod eich dewisiadau.")
        #expect("app_signOutAndDeleteAppDataButton".getWelshString() ==
                       "Mewngofnodi a dileu gwybodaeth")
    }
    
    @Test
    func test_signOutSuccessfulPageKeys() {
        #expect("app_signedOutTitle".getWelshString() ==
                       "Rydych wedi allfognodi")
        #expect("app_signedOutBody".getWelshString() ==
                       "Er mwyn cadw'ch gwybodaeth yn ddiogel, mae unrhyw ddogfennau yn yr ap hwn wedi'u dileu ac mae eich dewisiadau wedi'u hailosod.\n\nMae angen i chi fewngofnodi ac ailosod eich dewisiadau i barhau i ddefnyddio'r ap. Yna byddwch yn gallu ychwanegu eich dogfennau eto.")
    }
    
    @Test
    func test_signOutErrorPageKeys() {
        #expect("app_signOutErrorTitle".getWelshString() ==
                       "Roedd problem wrth eich allgofnodi")
        #expect("app_signOutErrorBody".getWelshString() ==
                       "Rhowch gynnig arall yn nes ymlaen.\n\nOs oes angen i chi fewngofnodi nawr, gallwch ddileu'r ap o'ch ffôn. Bydd hyn hefyd yn dileu unrhyw ddogfennau sydd wedi'u cadw yn eich ap.")
        #expect("app_signOutErrorButton".getWelshString() ==
                       "Yn ôl i gosodiadau")
    }
    
    @Test
    func test_signInAgainPageKeys() {
        #expect("app_signInAgainTitle".getWelshString() ==
                       "Mae angen i chi fewngofnodi eto")
        #expect("app_signInAgainBody".getWelshString() ==
                       "Mewngofnodwch gyda'ch manylion %@ i barhau.\n\nMae hyn er mwyn cadw'ch gwybodaeth yn ddiogel.")
    }
    
    @Test
    func test_dataDeletedWarningPageKeys() {
        #expect("app_dataDeletionWarningTitle".getWelshString() ==
                       "Mae rhywbeth wedi mynd o'i le")
        
        #expect("app_dataDeletionWarningBody".getWelshString() ==
                       "Ni allem gadarnhau eich manylion mewngofnodi.\n\nEr mwyn cadw eich gwybodaeth yn ddiogel, mae unrhyw ddogfennau yn eich ap wedi cael eu dileu ac mae eich dewisiadau wedi cael eu hailosod.\n\nMae angen i chi fewngofnodi ac ailosod eich dewisiadau i barhau i ddefnyddio'r ap. Yna byddwch yn gallu ychwanegu eich dogfennau eto.")
    }

    @Test
    func test_updateAppPageKeys() {
        #expect("app_updateAppTitle".getWelshString() ==
                       "Mae angen i chi ddiweddaru eich ap")
        #expect("app_updateAppBody".getWelshString() ==
                       "Rydych yn defnyddio hen fersiwn o'r ap %@.\n\nEwch i'r App Store a diweddarwch eich ap i barhau.")
        #expect("app_updateAppButton".getWelshString() ==
                       "Ewch i'r App Store")
    }
    
    @Test
    func test_homeTileKeys() {
        #expect("app_welcomeTileHeader".getWelshString() ==
                       "Croeso")
        #expect("app_welcomeTileBody1".getWelshString() ==
                       "Gallwch ddefnyddio'r ap hwn i brofi eich hunaniaeth i gael mynediad at rai gwasanaethau'r llywodraeth.")
        #expect("app_appPurposeTileHeader".getWelshString() ==
                       "Sut i brofi eich hunaniaeth")
        #expect("app_appPurposeTileBody1".getWelshString() ==
                       "I ddechrau, ewch i wefan GOV.UK a dewch o hyd i wasanaeth y llywodraeth rydych angen ei ddefnyddio. Gofynnir i chi agor yr ap hwn os ydych ei angen.")
        #expect("app_appPurposeTileButton".getWelshString() ==
                       "Darganfyddwch fwy")
    }
    
    @Test
    func test_proveIdentityGuidanceKeys() {
        #expect("app_proveYourIdentityGuidanceTitle".getWelshString() ==
                       "Sut i brofi eich hunaniaeth")
        #expect("app_proveYourIdentityGuidanceBody1".getWelshString() ==
                       "Ni allwch ddechrau profi eich hunaniaeth ar yr ap hwn.\n\nI ddechrau, ewch i wefan GOV.UK a dewch o hyd i wasanaeth y llywodraeth rydych angen ei ddefnyddio.\n\nGofynnir i chi agor yr ap hwn os ydych angen ei ddefnyddio i brofi eich hunaniaeth.")
        #expect("app_proveYourIdentityGuidanceLink".getWelshString() ==
                       "Ewch i wefan GOV.UK")
        #expect("app_proveYourIdentityGuidanceBody2".getWelshString() ==
                       "Os ydych eisoes wedi dechrau profi eich hunaniaeth ar wefan GOV.UK")
        #expect("app_proveYourIdentityGuidanceBody3".getWelshString() ==
                       "Os yw gwasanaeth wedi eich tywys i agor yr ap hwn, dylech weld botwm i barhau i brofi eich hunaniaeth yn yr adran 'Hafan'.\n\nOs na allwch weld y botwm, caewch yr ap a'i agor eto.")
    }
    
    @Test
    func test_appUnavailablePageKeys() {
        #expect("app_appUnavailableTitle".getWelshString() ==
                       "Mae'n ddrwg gennym, nid yw'r ap ar gael")
        #expect("app_appUnavailableBody".getWelshString() ==
                       "Ni allwch ddefnyddio'r ap %@ ar hyn o bryd.\n\nRhowch gynnig arall yn nes ymlaen.")
    }
    
    @Test
    func test_accessibilityHintKeys() {
        #expect("app_externalBrowser".getWelshString() == "Agor mewn porwr gwe")
        #expect("app_externalApp".getWelshString() == "Yn agor yn yr App Store")
        #expect("app_loadingLabel".getWelshString() == "Llwytho %@")
    }
    
    @Test
    func test_localAuthSettingsError_keys() {
        #expect("app_localAuthManagerErrorTitle".getWelshString() ==
                       "Diweddaru gosodiadau diogelwch eich ffôn")
        #expect("app_localAuthManagerErrorBody1".getWelshString() ==
                       "I ychwanegu dogfennau, mae angen i chi ddiogelu eich ffôn gyda chod mynediad.\n\nMae hyn er mwyn sicrhau na all unrhyw un arall weld na hychwanegu dogfennau at eich ap.")
        #expect("app_localAuthManagerErrorBody3".getWelshString() ==
                       "Mae angen i chi:")
        #expect("app_localAuthManagerErrorNumberedList0".getWelshString() ==
                       "Fynd i osodiadau eich ffôn.")
        #expect("app_localAuthManagerErrorNumberedList1FaceID".getWelshString() ==
                       "Tapio Face ID & Passcode.")
        #expect("app_localAuthManagerErrorNumberedList1TouchID".getWelshString() ==
                       "Tapio Touch ID & Passcode.")
        #expect("app_localAuthManagerErrorNumberedList2".getWelshString() ==
                       "Gwasgu Turn Passcode On a dilyn y cyfarwyddiadau.")
        #expect("app_localAuthManagerErrorNumberedList3".getWelshString() ==
                       "Dewch yn ôl i barhau i ddefnyddio eich dogfennau.")
    }
    
    @Test
    func test_localAuthBiometricsError_keys() {
        #expect("app_localAuthManagerBiometricsErrorTitle".getWelshString() ==
                       "Mae angen i chi ganiatáu %@")
        #expect("app_localAuthManagerBiometricsFaceIDErrorBody".getWelshString() ==
                       "I ychwanegu dogfennau, mae angen i chi ganiatáu Face ID. Mae hyn er mwyn cadw'ch dogfennau'n ddiogel.\n\nPan fyddwch yn caniatáu Face ID, bydd unrhyw un sy'n gallu datgloi eich ffôn gyda'u gwyneb neu gyda chod eich ffôn yn gallu cael mynediad i'ch ap.\n\nGallwch droi Face ID i ffwrdd ar gyfer yr ap hwn unrhyw bryd yng ngosodiadau eich ffôn.")
        #expect("app_localAuthManagerBiometricsTouchIDErrorBody".getWelshString() ==
                       "I ychwanegu dogfennau, mae angen i chi ganiatáu Touch ID. Mae hyn er mwyn cadw'ch dogfennau'n ddiogel.\n\nPan fyddwch yn caniatáu Touch ID, bydd unrhyw un sy'n gallu datgloi eich ffôn gyda'u olion bysedd neu gyda chod eich ffôn yn gallu cael mynediad i'ch ap.")
    }
    
    @Test
    func test_appIntegrityPageKeys() {
        #expect("app_appIntegrityErrorTitle".getWelshString() ==
                       "Mae'n ddrwg gennym, mae problem")
        #expect("app_appIntegrityErrorBody1".getWelshString() ==
                       "Ni allwch ddefnyddio'r ap %@ ar hyn o bryd.\n\nRhowch gynnig arall yn nes ymlaen.")
    }
}

// swiftlint:enable type_body_length
// swiftlint:enable line_length
