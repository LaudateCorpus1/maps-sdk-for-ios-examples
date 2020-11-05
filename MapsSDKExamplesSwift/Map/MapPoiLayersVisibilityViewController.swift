/**
 * Copyright (c) 2020 TomTom N.V. All rights reserved.
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
import TomTomOnlineSDKMaps
import UIKit

class MapPoiLayersVisibilityViewController: MapBaseViewController {
    var currentStyle: TTMapStyle!

    override func setupMap() {
        super.setupMap()
        currentStyle = mapView.styleManager.currentStyle
    }

    override func onMapReady() {
        super.onMapReady()
        let boundingBox = TTBoundingBox(topLeft: TTCoordinate.BERLIN_BOUNDINGBOX_LT(), withBottomRight: TTCoordinate.BERLIN_BOUNDINGBOX_RB())
        let cameraPosition = TTCameraBoundingBoxBuilder.create(with: boundingBox!).build()
        mapView.setCameraPosition(cameraPosition)
        mapView.poiDisplay.turnOnRichPoiLayer()
    }

    override func setupInitialCameraPosition() {}

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["All POI", "No POI", "Parks"], selectedID: 0)
    }

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)

        switch ID {
        case 0:
            mapView.poiDisplay.show()
        case 1:
            mapView.poiDisplay.hide()
        default:
            mapView.poiDisplay.hide()
            mapView.poiDisplay.show(["Park & Recreation Area"])
        }
    }
}
