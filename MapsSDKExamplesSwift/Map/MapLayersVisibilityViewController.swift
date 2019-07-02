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

class MapLayersVisibilityViewController: MapBaseViewController {
    
    var currentStyle: TTMapStyle!

    override func setupMap() {
        super.setupMap()
        currentStyle = mapView.styleManager.currentStyle
    }
    
    override func onMapReady() {
        turnOffLayers()
    }
    
    override func setupCenterOnWillHappen() {
        mapView.center(on: TTCoordinate.BERLIN(), withZoom: 8)
    }
    
    override func getOptionsView() -> OptionsView {
        return OptionsViewMultiSelect(labels: ["Road network", "Woodland", "Build-up"], selectedID: -1)
    }
    
    //MARK: OptionsViewDelegate
    
    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        let visibility:TTMapLayerVisibility = on ? .visible : .none
        var layers:[TTMapLayer] = []
        switch ID {
        case 2:
            layers = currentStyle.getLayersBySourceLayerRegex("Built-up area")
        case 1:
            layers = currentStyle.getLayersBySourceLayerRegex("Woodland.*")
        default:
            layers = currentStyle.getLayersBySourceLayerRegexs([".*[rR]oad.*", ".*[mM]otorway.*"])
        }
        changeLayers(layers, withVisibility: visibility)
    }
    
    func changeLayers(_ layers: [TTMapLayer], withVisibility visibility:TTMapLayerVisibility) {
        layers.forEach { layer in
            layer.visibility = visibility
        }
    }
    
    func turnOffLayers() {
        let layers = currentStyle.getLayersBySourceLayerRegexs(["Built-up area", "Woodland.*", ".*[rR]oad.*", ".*[mM]otorway.*"])
        changeLayers(layers, withVisibility: .none)
    }

}
