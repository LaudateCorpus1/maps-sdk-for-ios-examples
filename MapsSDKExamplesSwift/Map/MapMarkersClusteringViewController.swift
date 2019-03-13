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

class MapMarkersClusteringViewController: MapBaseViewController {
    
    override func setupCenterOnWillHappen() {}
    
    override func onMapReady() {
        super.onMapReady()
        mapView.zoomToAllAnnotations()
    }
    
    override func setupMap() {
        super.setupMap()
        mapView.annotationManager.clustering = true
        addRandomMarkers()
    }
    
    private func addRandomMarkers() {
        for _ in 0..<90 {
            let coordinate = CLLocation.makeRandomCoordinateForCenteroid(center: TTCoordinate.AMSTERDAM())
            let annotation = TTAnnotation(coordinate: coordinate)
            annotation.shouldCluster = true
            mapView.annotationManager.add(annotation)
        }
        for _ in 0..<150 {
            let coordinate = CLLocation.makeRandomCoordinateForCenteroid(center: TTCoordinate.ROTTERDAM())
            let annotation = TTAnnotation(coordinate: coordinate)
            annotation.shouldCluster = true
            mapView.annotationManager.add(annotation)
        }
    }

}
