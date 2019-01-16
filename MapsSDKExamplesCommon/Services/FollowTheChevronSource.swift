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

import Foundation
import TomTomOnlineSDKMaps
import CoreLocation

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
        prevCoordinate = MapFollowTheChevronSource.coordinateForValue(value: self.mapRoute.coordinatesData()[0])
    }

    public static func coordinateForValue(value: NSValue) -> CLLocationCoordinate2D {
        var coordiante = CLLocationCoordinate2DMake(0, 0)
        value.getValue(&coordiante)
        return coordiante;
    }

    public func activate() {
        // Start Service
        var index = 0;
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in

            index = index + 1;
            if index == self.mapRoute.coordinatesData().count {
                index = 0;
            }
            let coordiante = MapFollowTheChevronSource.coordinateForValue(value: self.mapRoute.coordinatesData()[index])
            let bearing = self.bearingWithCoordinate(coordinate: coordiante, prevCoordianate: self.prevCoordinate!)
            let location = TTLocation(coordinate: coordiante, withBearing: bearing)
            self.manager.update(self.object, with: location)
            
            self.prevCoordinate = coordiante
        })
    }

    public func deactivate() {
        // Stop Service
        timer?.invalidate()
    }

    func bearingWithCoordinate(coordinate: CLLocationCoordinate2D, prevCoordianate: CLLocationCoordinate2D) -> Double {
        let prevLatitude = degreesToRadians(prevCoordianate.latitude)
        let prevLongitude = degreesToRadians(prevCoordianate.longitude)
        let latitude = degreesToRadians(coordinate.latitude)
        let longitude = degreesToRadians(coordinate.longitude)

        let degree = radiansToDegress(atan2(sin(longitude-prevLongitude)*cos(latitude),
                                            cos(prevLatitude)*sin(latitude)-sin(prevLatitude)*cos(latitude)*cos(longitude-prevLongitude)))

        if degree >= 0 {
            return degree;
        } else {
            return 360.0 + degree;
        }
    }

    func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * Double.pi / 180
    }

    func radiansToDegress(_ radians: Double) -> Double {
        return radians * 180 / Double.pi
    }
}
