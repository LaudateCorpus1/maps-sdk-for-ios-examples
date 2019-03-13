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

import UIKit
import MapsSDKExamplesCommon
import MapsSDKExamplesVC
import TomTomOnlineSDKMaps

class MapTilesViewController: MapBaseViewController {

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Vector", "Raster"], selectedID: 0)
    }
    
    //MARK: OptionsViewDelegate
    
    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        switch ID {
        case 1:
            displayRaster()
        default:
            displayVectors()
        }
    }
    
    //MARK: Examples
    
    func displayVectors() {
        mapView.setTilesType(.vector)
    }
    
    func displayRaster() {
        mapView.setTilesType(.raster)
    }

}
