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

class MapPerspectiveViewController: MapBaseViewController {
    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["2D mode", "3D mode"], selectedID: 0)
    }

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        switch ID {
        case 1:
            set3DMode()
        default:
            set2DMode()
        }
    }

    // MARK: Examples

    func set2DMode() {
        mapView.setPerspective3D(false)
    }

    func set3DMode() {
        mapView.setPerspective3D(true)
    }
}
