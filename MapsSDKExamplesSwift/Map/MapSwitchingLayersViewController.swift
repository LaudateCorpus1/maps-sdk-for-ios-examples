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

class MapSwitchingLayersViewController: MapBaseViewController {
    
    override func onMapReady() {
        turnOffLayers()
    }
    
    override func setupCenterOnWillHappen() {
        mapView.center(on: TTCoordinate.BERLIN(), withZoom: 8)
    }
    
    override func getOptionsView() -> OptionsView {
        return OptionsViewMultiSelect(labels: ["Road network", "Woodland", "Build-up"], selectedID: -1)
    }
    
    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        switch ID {
        case 2:
            self.mapView.setVisible(on, ofSourceLayers: "Built-up area")
            break;
        case 1:
            self.mapView.setVisible(on, ofSourceLayers: "Woodland.*")
            break;
        default:
            self.mapView.setVisible(on, ofSourceLayers: ".*road.*")
            self.mapView.setVisible(on, ofSourceLayers: ".*Road.*")
            self.mapView.setVisible(on, ofSourceLayers: ".*Motorway.*")
            self.mapView.setVisible(on, ofSourceLayers: ".*motorway.*")
            break;
        }
    }
    
    func turnOffLayers() {
        self.mapView.setVisible(false, ofSourceLayers: "Built-up area")
        self.mapView.setVisible(false, ofSourceLayers: "Woodland.*")
        self.mapView.setVisible(false, ofSourceLayers: ".*road.*")
        self.mapView.setVisible(false, ofSourceLayers: ".*Road.*")
        self.mapView.setVisible(false, ofSourceLayers: ".*Motorway.*")
        self.mapView.setVisible(false, ofSourceLayers: ".*motorway.*")
    }

}
