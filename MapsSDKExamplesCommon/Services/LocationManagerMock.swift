/**
 * Copyright (c) 2021 TomTom N.V. All rights reserved.
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

@objc public protocol LocationManagerMockDelegate {
    func didUpdateLocation(_ location: CLLocation)
}

@objc open class LocationManagerMock: NSObject, TTLocationSource {
    private let NEXT_POINT_TIME_DIFF_IN_MILLIS: Double = 1000
    private let NUMBER_OF_MILLIS_IN_HOUR: Double = 1000 * 60 * 60
    private let MAX_SPEED = 150.0
    private let MIN_SPEED = 0.0

    let route: TTMapRoute
    var timer: Timer?
    var prevCoordinate: CLLocationCoordinate2D?
    var speeds: [Double] = [0.0]

    @objc public var delegate: LocationManagerMockDelegate?

    @objc public init(route: TTMapRoute) {
        self.route = route
        super.init()

        calculateSpeeds()
        normalizeSpeeds()
        prevCoordinate = LocationUtils.coordinateForValue(value: route.coordinatesData()[0])
    }

    public func activate() {
        var index = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            index = index + 1
            if index == self.route.coordinatesData().count {
                index = 0
            }
            let coordiante = LocationUtils.coordinateForValue(value: self.route.coordinatesData()[index])
            let bearing = LocationUtils.bearingWithCoordinate(coordinate: coordiante, prevCoordianate: self.prevCoordinate!)

            let location = CLLocation(coordinate: coordiante, altitude: 0.0, horizontalAccuracy: Double.random(in: 1.0 ... 25), verticalAccuracy: Double.random(in: 1.0 ... 25), course: bearing, speed: self.speeds[index], timestamp: Date())
            self.prevCoordinate = coordiante
            self.delegate?.didUpdateLocation(location)
        })
    }

    public func deactivate() {
        timer?.invalidate()
    }

    private func calculateSpeeds() {
        guard let coordsData = route.coordinatesData() else { return }
        let locations = coordsData.map { CLLocation($0.mkCoordinateValue) }

        for (index, location) in locations.enumerated() {
            guard index < locations.count - 1 else { return }
            let nextLocation = locations[index + 1]
            let distanceInMeters = location.distance(from: nextLocation)
            let timeInHours = NEXT_POINT_TIME_DIFF_IN_MILLIS / NUMBER_OF_MILLIS_IN_HOUR
            let speedInKMH = (distanceInMeters / 1000.0) / timeInHours
            speeds.append(speedInKMH)
        }
    }

    private func normalizeSpeeds() {
        if let minSpeed = speeds.min(),
           let maxSpeed = speeds.max()
        {
            for index in speeds.indices {
                speeds[index] = max(MIN_SPEED, min(MAX_SPEED, MAX_SPEED * (speeds[index] - minSpeed) / (maxSpeed - minSpeed)))
            }
        }
    }
}
