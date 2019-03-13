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

class MapShapesViewController: MapBaseViewController, TTAnnotationDelegate {

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Polygon", "Polyline", "Circle"], selectedID: -1)
    }
    
    override func setupMap() {
        super.setupMap()
        mapView.annotationManager.delegate = self
    }
    
    //MARK: OptionsViewDelegate
    
    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        mapView.annotationManager.removeAllOverlays()
        switch ID {
        case 2:
            displayCircle()
        case 1:
            displayPolyline()
        default:
            displayPolygon()
        }
    }
    
    //MARK: Examples
    
    func displayPolygon() {
        let color = UIColor.random
        let pointsCount = 24
        var coordinates = CLLocation.makeCoordinatesInCenterArea(center: TTCoordinate.AMSTERDAM(), pointsCount: pointsCount)
        let polygon = TTPolygon(coordinates: &coordinates, count: UInt(pointsCount), opacity: 1, color: color, colorOutline: color)
        mapView.annotationManager.add(polygon)
    }
    
    func displayPolyline() {
        let color = UIColor.random
        let pointsCount = 24
        var coordinates = CLLocation.makeCoordinatesInCenterArea(center: TTCoordinate.AMSTERDAM(), pointsCount: pointsCount)
        let polyline = TTPolyline(coordinates: &coordinates, count: UInt(pointsCount), opacity: 1, width: 8, color: color)
        mapView.annotationManager.add(polyline)
    }
    
    func displayCircle() {
        let color = UIColor.random
        let circle = TTCircle(center: TTCoordinate.AMSTERDAM(), radius: 5000, opacity: 1, width: 10, color: color, fill: true, colorOutlet: color)
        mapView.annotationManager.add(circle)
    }
    
    //MARK: TTAnnotationDelegate
    
    func annotationManager(_ manager: TTAnnotationManager, touchUp polygon: TTPolygon) {
        //called when polygon clicked
    }
    
    func annotationManager(_ manager: TTAnnotationManager, touchUp circle: TTCircle) {
        //called when circle clicked
    }
    
    func annotationManager(_ manager: TTAnnotationManager, touchUp polyline: TTPolyline) {
        //called when polyline clicked
    }

}
