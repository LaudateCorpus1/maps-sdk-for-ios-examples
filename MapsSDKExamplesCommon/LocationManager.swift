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

public class LocationManager: NSObject, CLLocationManagerDelegate {
    
    @objc public static let shared = LocationManager()
    
    let osManager: CLLocationManager
    @objc public var lastLocation: CLLocation?
    
    override init() {
        osManager = CLLocationManager()
        super.init()
        osManager.delegate = self
    }
    
    @objc public func start() {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            osManager.requestWhenInUseAuthorization()
        } else {
            osManager.startUpdatingLocation()
        }
    }
    
    @objc public func stop() {
        osManager.stopUpdatingLocation()
    }
    
    //MARK: CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            osManager.startUpdatingLocation()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        lastLocation = location
    }
    
}
