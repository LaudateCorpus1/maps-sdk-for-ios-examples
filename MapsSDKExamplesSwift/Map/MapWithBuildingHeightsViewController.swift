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

class MapWithBuildingHeightsViewController: MapBaseViewController {
    var layers: [TTMapLayer]! = []

    override func setupInitialCameraPosition() {
        mapView.center(on: TTCoordinate.LONDON(), withZoom: 17)
    }

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Heights", "Footprints"], selectedID: 0)
    }

    override func onMapReady() {
        super.onMapReady()
        layers = mapView.styleManager.currentStyle.getLayersByRegexs(["Subway Station 3D",
                                                                      "Place of worship 3D",
                                                                      "Railway Station 3D",
                                                                      "Government Administration Office 3D",
                                                                      "Other building 3D",
                                                                      "School building 3D",
                                                                      "Other town block 3D",
                                                                      "Factory building 3D",
                                                                      "Hospital building 3D",
                                                                      "Hotel building 3D",
                                                                      "Cultural Facility 3D"])
        buildingHeights()
    }

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        switch ID {
        case 1:
            buildingFootprints()
        default:
            buildingHeights()
        }
    }

    // MARK: Examples

    func buildingFootprints() {
        changeLayers(layers, withVisibility: .none)
        mapView.setPerspective3D(false)
    }

    func buildingHeights() {
        changeLayers(layers, withVisibility: .visible)
        mapView.setPerspective3D(true)
    }

    func changeLayers(_ layers: [TTMapLayer], withVisibility visibility: TTMapLayerVisibility) {
        layers.forEach { layer in
            layer.visibility = visibility
        }
    }
}
