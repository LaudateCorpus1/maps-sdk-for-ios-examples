//
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
import TomTomOnlineSDKRouting

@objc public class RouteOptions: NSObject, RouteProtocol {
    @objc public var routeType: RouteType

    @objc public var considerTraffic: Bool

    @objc public var avoidTypes: [AvoidType] = []

    @objc public var travelMode: TravelMode

    @objc public init(routeType: RouteType, considerTraffic: Bool, avoidTypes: [AvoidType], travelMode: TravelMode) {
        self.routeType = routeType
        self.considerTraffic = considerTraffic
        self.avoidTypes = avoidTypes
        self.travelMode = travelMode
    }

    @objc public static var fastestWithoutTraffic: RouteOptions {
        return RouteOptions(routeType: .fastest, considerTraffic: false, avoidTypes: [], travelMode: .car)
    }
}
