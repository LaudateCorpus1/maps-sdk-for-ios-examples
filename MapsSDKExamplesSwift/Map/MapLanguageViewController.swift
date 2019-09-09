/**
 * Copyright (c) 2019 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its subsidiaries and may be used
 * for internal evaluation purposes or commercial use strictly subject to separate licensee
 * agreement between you and TomTom. If you are the licensee, you are only permitted to use
 * this Software in accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and should
 * immediately return it to TomTom N.V.
 */

import MapsSDKExamplesCommon
import MapsSDKExamplesVC
import UIKit

class MapLanguageViewController: MapBaseViewController {
    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["English", "Russian", "Dutch"], selectedID: 0)
    }

    override func setupMap() {
        super.setupMap()
        mapView.setLanguage("en-GB")
    }

    override func setupCenterOnWillHappen() {
        mapView.center(on: TTCoordinate.LODZ(), withZoom: 3.2)
    }

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        switch ID {
        case 2:
            setLanguageDutch()
        case 1:
            setLanguageRussian()
        default:
            setLanguageEnglish()
        }
    }

    // MARK: Examples

    func setLanguageEnglish() {
        mapView.setLanguage("en-GB")
    }

    func setLanguageRussian() {
        mapView.setLanguage("ru-RU")
    }

    func setLanguageDutch() {
        mapView.setLanguage("nl-NL")
    }
}
