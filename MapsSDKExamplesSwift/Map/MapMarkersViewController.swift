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

class MapMarkersViewController: MapBaseViewController {

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Simple", "Decal"], selectedID: -1)
    }

    //MARK: OptionsViewDelegate
    
    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        switch ID {
        case 1:
            displayDecalMarkers()
        default:
            displaySimpleMarkers()
        }
    }
    
    //MARK: Examples
    
    func displaySimpleMarkers() {
        mapView.bearing = 0
        mapView.annotationManager.removeAllAnnotations()
        for _ in 0...4 {
            let cooridnate = CLLocation.makeRandomCoordinateForCenteroid(center: TTCoordinate.AMSTERDAM())
            let annotation = TTAnnotation(coordinate: cooridnate)
            mapView.annotationManager.add(annotation)
        }
    }
    
    func displayDecalMarkers() {
        mapView.bearing = 180
        mapView.annotationManager.removeAllAnnotations()
        for _ in 0...4 {
            let cooridnate = CLLocation.makeRandomCoordinateForCenteroid(center: TTCoordinate.AMSTERDAM())
            let customIcon = TTAnnotationImage.createPNG(withName: "Favourite")!
            let annotation = TTAnnotation(coordinate: cooridnate, annotationImage: customIcon, anchor: .bottom, type: .decal)
            mapView.annotationManager.add(annotation)
        }
    }

}
