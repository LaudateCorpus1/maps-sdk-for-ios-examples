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
    let manager: TTTrackingManager
    let object: TTChevronObject
    let mapRoute: TTMapRoute
    var timer: Timer?
    var prevCoordinate: CLLocationCoordinate2D?

    @objc public init(trackingManager: TTTrackingManager, trackingObject: TTChevronObject, route: TTMapRoute) {
        manager = trackingManager
        object = trackingObject
        mapRoute = route
        prevCoordinate = LocationUtils.coordinateForValue(value: mapRoute.coordinatesData()[0])
        let location = TTLocation(coordinate: prevCoordinate!, withBearing: 0)
        manager.update(object, with: location)
        object.isHidden = false
    }

    public func activate() {
        // Start Service
        var index = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in

            index = index + 1
            if index == self.mapRoute.coordinatesData().count {
                index = 0
            }
            let coordiante = LocationUtils.coordinateForValue(value: self.mapRoute.coordinatesData()[index])
            let bearing = LocationUtils.bearingWithCoordinate(coordinate: coordiante, prevCoordianate: self.prevCoordinate!)
            let location = TTLocation(coordinate: coordiante, withBearing: bearing)
            self.manager.update(self.object, with: location)
            self.prevCoordinate = coordiante
        })
    }

    public func deactivate() {
        // Stop Service
        timer?.invalidate()
    }
}
