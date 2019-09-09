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
import TomTomOnlineUtils

@objc public class RandomizeCoordinate: NSObject {
    @objc public class func interpolate(coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let precision: Double = 0.00010
        let beginningOfTheRange = Float(-precision)
        let endOfTheRange = Float(precision)
        let diff: Float = endOfTheRange - beginningOfTheRange

        let foundLatitude = Float(coordinate.latitude) + ((Float(UInt(arc4random()) % (UInt(RAND_MAX) + 1)) / Float(RAND_MAX)) * diff) + beginningOfTheRange
        let foundLongitude = Float(coordinate.longitude) + ((Float(UInt(arc4random()) % (UInt(RAND_MAX) + 1)) / Float(RAND_MAX)) * diff) + beginningOfTheRange

        return CLLocationCoordinate2DMake(CLLocationDegrees(foundLatitude), CLLocationDegrees(foundLongitude))
    }
}
