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
import CoreLocation
import MapsSDKExamplesCommon
import MapsSDKExamplesVC
import TomTomOnlineSDKMaps


class MapAdvancedMarkersViewController: MapBaseViewController {
    
    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Animated", "Draggable"], selectedID: -1)
    }
    
    //MARK: OptionsViewDelegate
    
    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        switch ID {
        case 1:
            displayDraggableMarker()
        default:
            displayAnimatedMarkers()
        }
    }
    
    //MARK: Examples
    
    func displayAnimatedMarkers() {
        mapView.annotationManager.removeAllAnnotations()
        for _ in 0...4 {
            let cooridnate = CLLocation.makeRandomCoordinateForCenteroid(center: TTCoordinate.AMSTERDAM())
            let customIcon = TTAnnotationImage.createGIF(withName: "gif_annotation")!
            let annotation = TTAnnotation(coordinate: cooridnate, annotationImage: customIcon, anchor: .bottom, type: .decal)
            mapView.annotationManager.add(annotation)
        }
    }
    
    func displayDraggableMarker() {
        mapView.annotationManager.removeAllAnnotations()
        for _ in 0...4 {
            let cooridnate = CLLocation.makeRandomCoordinateForCenteroid(center: TTCoordinate.AMSTERDAM())
            let annotation = TTAnnotation(coordinate: cooridnate)
            annotation.isDraggable = true
            mapView.annotationManager.add(annotation)
        }
    }
    
}

