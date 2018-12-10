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

public extension CLLocation {
    
    @objc convenience public init(_ coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    @objc static public func makeCoordinatesInCenterArea(center: CLLocationCoordinate2D, pointsCount: Int) -> [CLLocationCoordinate2D] {
        let map_zoom = 10
        let radius = 128.0 / Double(1 << map_zoom)
        let degreesPerPoint = 360.0 / Double(pointsCount)
        let centerSpaceRation = 0.8
        var coordinates: [CLLocationCoordinate2D] = []
        for i in 0..<pointsCount {
            let dist = radius * centerSpaceRation + radius * (1.0 - centerSpaceRation) * Math.randomRatio()
            let angle = Double(i) * degreesPerPoint + Math.randomRatio() * degreesPerPoint
            let y = sin(Math.deg2rad(angle)) * dist
            let x = cos(Math.deg2rad(angle)) * dist
            coordinates.append(CLLocationCoordinate2D(latitude: center.latitude + y, longitude: center.longitude + x))
        }
        return coordinates
    }

    @objc static public func makeRandomCoordinateForCenteroid(center: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let latitude = Math.randBetween(low: center.latitude - 0.1, high: center.latitude + 0.1)
        let longitude = Math.randBetween(low: center.longitude - 0.1, high: center.longitude + 0.1)
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    @objc static public func locationsEquals(first: CLLocationCoordinate2D, second: CLLocationCoordinate2D) -> Bool {
        return (fabs(first.latitude - second.latitude) < .ulpOfOne) && (fabs(first.longitude - second.longitude) < .ulpOfOne)
    }

}
