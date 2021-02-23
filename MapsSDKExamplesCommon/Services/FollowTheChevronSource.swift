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

import CoreLocation
import Foundation
import TomTomOnlineSDKMaps

@objc open class MapFollowTheChevronSource: NSObject, TTLocationSource {
    let trackingManager: TTTrackingManager
    let routeManager: TTRouteManager
    let object: TTChevronObject
    let mapRoute: TTMapRoute
    var timer: Timer?
    var prevCoordinate: CLLocationCoordinate2D?

    @objc public init(trackingManager: TTTrackingManager, routeManager: TTRouteManager, trackingObject: TTChevronObject, route: TTMapRoute) {
        self.trackingManager = trackingManager
        self.routeManager = routeManager
        object = trackingObject
        mapRoute = route
        prevCoordinate = LocationUtils.coordinateForValue(value: mapRoute.coordinatesData()[0])
        let location = TTLocation(coordinate: prevCoordinate!, withBearing: 0)
        trackingManager.update(object, with: location)
        object.isHidden = true
        let style = TTMapRouteStyleLayerBuilder().withColor(UIColor(red: 255 / 255, green: 153 / 255, blue: 0, alpha: 1.0)).build()
        routeManager.activateProgress(alongTheRoute: route, withStyling: style)
    }

    public func activate() {
        // Start Service
        var index = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            self.object.isHidden = false
            index = index + 1
            if index == self.mapRoute.coordinatesData().count {
                index = 0
            }
            let coordiante = LocationUtils.coordinateForValue(value: self.mapRoute.coordinatesData()[index])
            let bearing = LocationUtils.bearingWithCoordinate(coordinate: coordiante, prevCoordianate: self.prevCoordinate!)
            let location = TTLocation(coordinate: coordiante, withBearing: bearing)
            self.trackingManager.update(self.object, with: location)
            self.prevCoordinate = coordiante
            self.routeManager.updateProgress(alongTheRoute: self.mapRoute, with: location)
        })
    }

    public func deactivate() {
        // Stop Service
        timer?.invalidate()
        routeManager.deactivateProgress(alongTheRoute: mapRoute)
    }
}
