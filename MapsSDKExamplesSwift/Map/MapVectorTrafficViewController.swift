/**
 * Copyright (c) 2018 TomTom N.V. All rights reserved.
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

class MapVectorTrafficViewController: MapBaseViewController {

    override func setupCenterOnWillHappen() {
        mapView.center(on: TTCoordinate.LONDON(), withZoom: 12)
    }
    
    override func setupMap() {
        super.setupMap()
        mapView.setTilesType(.vector)
        mapView.trafficTileStyle = TTVectorTileType.setStyle(.relative)
    }
    
    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Flow", "No traffic"], selectedID: 1)
    }
    
    //MARK: OptionsViewDelegate
    
    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        switch ID {
        case 1:
            hideFLow()
        default:
            displayFlow()
        }
    }
    
    //MARK: Examples
    
    func displayFlow() {
        mapView.trafficFlowOn = true
    }
    
    func hideFLow() {
        mapView.trafficFlowOn = false
    }

}
