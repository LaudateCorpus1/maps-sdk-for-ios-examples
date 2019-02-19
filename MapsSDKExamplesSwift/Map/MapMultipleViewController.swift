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
import TomTomOnlineSDKMaps

class MapMultipleViewController: MapBaseViewController, TTMapViewDelegate {
    
    override func setupCenterOnWillHappen() {
        mapView.center(on: TTCoordinate.AMSTERDAM(), withZoom: 12)
    }
    
    weak var secoundMap:TTMapView!
    
    override func setupMap() {
        super.setupMap()
        mapView.delegate = self
    }
    
    override func onMapReady() {
        super.onMapReady()
        self.setupSecoundMap()
    }
    
    func setupSecoundMap() {
        let map = TTMapView(frame: CGRect.zero)
        self.secoundMap = map
        self.secoundMap.clipsToBounds = true
        self.secoundMap.layer.borderColor = UIColor.white.cgColor
        self.secoundMap.layer.borderWidth = TTSecoundMap.SecoundMapBorderSize()
        let customStyle = Bundle.main.path(forResource: "style", ofType: "json")
        secoundMap.setStylePath(customStyle)
        super.mapView.addSubview(secoundMap)
        self.setupConstrains()
        self.secoundMap.setCameraPosition(TTCameraPositionBuilder.create(withCameraPosition: TTCoordinate.AMSTERDAM()).withZoom(8).build())
        drowShapes()
    }
    
    //MARK: TTMapViewDelegate
    func mapView(_ mapView: TTMapView, didChangedCameraPosition cameraPosition: TTCameraPosition) {
        updateSecoundMap(coordinate: cameraPosition.cameraPosition)
    }

    func drowShapes() {
        self.secoundMap.annotationManager.removeAllOverlays()
        var coordinates: [CLLocationCoordinate2D] = []
        coordinates.append(self.mapView.currentBounds().nwBounds)
        coordinates.append(CLLocationCoordinate2D(latitude: self.mapView.currentBounds().nwBounds.latitude, longitude: self.mapView.currentBounds().seBounds.longitude))
        coordinates.append(self.mapView.currentBounds().seBounds)
        coordinates.append(CLLocationCoordinate2D(latitude: self.mapView.currentBounds().seBounds.latitude, longitude: self.mapView.currentBounds().nwBounds.longitude))
        coordinates.append(self.mapView.currentBounds().nwBounds)
        let color = UIColor.yellow
        let pointsCount = 5
        let polyLine = TTPolyline(coordinates: &coordinates, count: (UInt(pointsCount)), opacity: 1, width: 1.0, color: color)
        self.secoundMap.annotationManager.add(polyLine)
    }
    
    func updateSecoundMap(coordinate: CLLocationCoordinate2D) {
        if(self.secoundMap != nil){
            drowShapes()
            self.secoundMap.setCameraPosition(TTCameraPositionBuilder.create(withCameraPosition: coordinate).build())
            
        }
    }
    
    func setupConstrains() {
        let mapSize = super.mapView.bounds.width / 2
        self.secoundMap.translatesAutoresizingMaskIntoConstraints = false
        self.secoundMap.heightAnchor.constraint(equalToConstant: mapSize).isActive = true
        self.secoundMap.widthAnchor.constraint(equalToConstant: mapSize).isActive = true
        self.secoundMap.topAnchor.constraint(equalTo: self.mapView.topAnchor, constant: 5).isActive = true
        self.secoundMap.rightAnchor.constraint(equalTo: self.mapView.rightAnchor, constant: -5).isActive = true
        self.secoundMap.layer.cornerRadius = mapSize / 2
    }
}
