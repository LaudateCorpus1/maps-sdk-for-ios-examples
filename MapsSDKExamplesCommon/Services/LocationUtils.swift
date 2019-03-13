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

import Foundation
import CoreLocation

@objc public class LocationUtils : NSObject {

    @objc public static func coordinateForValue(value: NSValue) -> CLLocationCoordinate2D {
        var coordiante = CLLocationCoordinate2DMake(0, 0)
        value.getValue(&coordiante)
        return coordiante;
    }

    @objc public static func bearingWithCoordinate(coordinate: CLLocationCoordinate2D, prevCoordianate: CLLocationCoordinate2D) -> Double {
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

    @objc public static func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * Double.pi / 180
    }

    @objc public static func radiansToDegress(_ radians: Double) -> Double {
        return radians * 180 / Double.pi
    }
}
