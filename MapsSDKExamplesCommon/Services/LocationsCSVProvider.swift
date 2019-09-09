/**
 * Copyright (c) 2017 TomTom N.V. All rights reserved.
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

@objc public class LocationCSVProvider: NSObject {
    let TIME_COL_IDX: Int = 0
    let PROVIDER_COL_IDX: Int = 1
    let LATITUDE_COL_IDX: Int = 2
    let LONGITUDE_COL_IDX: Int = 3
    let ACCURACY_COL_IDX: Int = 4
    let BEARING_COL_IDX: Int = 5
    let SPEED_COL_IDX: Int = 7
    let ALTITUDE_COL_IDX: Int = 9

    @objc public var locations: [ProviderLocation] = []

    @objc public init(csvFile filename: String?) {
        let strPath = Bundle.main.path(forResource: filename, ofType: "csv")
        let strFile = try? String(contentsOfFile: strPath ?? "", encoding: .utf8)

        if strFile == nil {
            print("Error reading file.")
        }

        let correntCountComponents = 11

        var contentArray = [Any]()
        if let components = strFile?.components(separatedBy: "\n") {
            contentArray = components
        }
        locations = [ProviderLocation]()

        for object in contentArray {
            let components = (object as AnyObject).components(separatedBy: ",")
            if components.count < correntCountComponents {
                return
            }
            let time = Double(components[TIME_COL_IDX].trimmingCharacters(in: NSCharacterSet.whitespaces))!
            let lat = Double(components[LATITUDE_COL_IDX].trimmingCharacters(in: NSCharacterSet.whitespaces))!
            let lon = Double(components[LONGITUDE_COL_IDX].trimmingCharacters(in: NSCharacterSet.whitespaces))!
            let accuracy = Double(components[ACCURACY_COL_IDX].trimmingCharacters(in: NSCharacterSet.whitespaces))!
            let bearing = Double(components[BEARING_COL_IDX].trimmingCharacters(in: NSCharacterSet.whitespaces))!
            let speed = Double(components[SPEED_COL_IDX].trimmingCharacters(in: NSCharacterSet.whitespaces))!
            let altitude = Double(components[ALTITUDE_COL_IDX].trimmingCharacters(in: NSCharacterSet.whitespaces))!

            let providerLocation = ProviderLocation(coordinate: CLLocationCoordinate2DMake(lat, lon), withRadius: 0.0, withBearing: bearing, withAccuracy: accuracy)
            providerLocation.timestamp = time
            providerLocation.speed = speed
            providerLocation.altitude = altitude

            locations.append(providerLocation)
        }
    }
}
