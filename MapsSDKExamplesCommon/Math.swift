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

class Math: NSObject {
    
    private static let ARC4RANDOM_MAX: Double = 0x100000000

    static func randBetween(low: Double, high: Double) -> Double {
        return (Double(arc4random()) / Math.ARC4RANDOM_MAX * (high - low)) + low
    }
    
    static func randomRatio() -> Double {
        return Double(arc4random() & 0xFFFF) / Double(0xFFFF)
    }
    
    static func deg2rad(_ degrees: Double) -> Double {
        return degrees * (Double.pi / 180.0)
    }

}
