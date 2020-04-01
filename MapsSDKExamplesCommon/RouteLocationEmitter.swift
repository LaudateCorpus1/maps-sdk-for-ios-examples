//
/**
 * Copyright (c) 2020 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its subsidiaries and may be used
 * for internal evaluation purposes or commercial use strictly subject to separate licensee
 * agreement between you and TomTom. If you are the licensee, you are only permitted to use
 * this Software in accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and should
 * immediately return it to TomTom N.V.
 */

import Foundation

@objc public protocol RouteLocationEmitterDelegate: class {
    func routeLocationEmitter(_ emitter: RouteLocationEmitter, didEmitt location: ProviderLocation)
}

@objc public class RouteLocationEmitter: NSObject {
    @objc public weak var delegate: RouteLocationEmitterDelegate?

    var timers: [Timer] = []

    let routeProvider: LocationCSVProvider

    @objc public init(routeProvider: LocationCSVProvider) {
        self.routeProvider = routeProvider
        super.init()
    }

    @objc public func stop() {
        timers.forEach { $0.invalidate() }
        timers.removeAll()
    }

    @objc public func startEmitting() {
        stop()
        var accumulatedTime = 0.0

        for index in 1 ... routeProvider.locations.count - 1 {
            let prev = routeProvider.locations[index - 1]
            let next = routeProvider.locations[index]
            let providerLocation = ProviderLocation(coordinate: next.coordinate, withRadius: next.radius, withBearing: next.bearing, withAccuracy: next.accuracy)
            providerLocation.timestamp = next.timestamp
            providerLocation.speed = next.speed
            let time = (next.timestamp - prev.timestamp) / 1000
            accumulatedTime = accumulatedTime + time
            let timer = Timer.scheduledTimer(withTimeInterval: accumulatedTime, repeats: false) { [weak self] t in
                t.invalidate()
                guard let self = self else { return }
                self.delegate?.routeLocationEmitter(self, didEmitt: providerLocation)
            }
            timers.append(timer)
        }
    }
}
