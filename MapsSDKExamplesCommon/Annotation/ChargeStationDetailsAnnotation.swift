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
import TomTomOnlineSDKMaps
import TomTomOnlineSDKSearch

extension ChargingStationDetails {
    func isOccupied() -> Bool {
        guard let first = self.chargingStation.connectors.first else { return false }
        return first.availability.available == 0
    }
}

@objc public class ChargeStationDetailsAnnotation: TTAnnotation {
    @objc public let info: ChargingStationDetails

    @objc public init(info: ChargingStationDetails) {
        self.info = info

        let image: TTAnnotationImage

        if info.isOccupied() {
            image = TTAnnotationImage.createPNG(withName: "pin_red")!
        } else {
            image = TTAnnotationImage.createPNG(withName: "pin_green")!
        }

        super.init(coordinate: info.position, annotationImage: image, anchor: .bottom, type: .focal)
    }

    @objc public func readableAvailability() -> String {
        let total = info.chargingStation.connectors.first?.total ?? 0
        let available = info.chargingStation.connectors.first?.availability.available ?? 0
        let type = info.chargingStation.connectors.first?.type ?? "-"
        return "\(available)/\(total) of available \(type)"
    }

    @objc public func freeFormAddress() -> String {
        return info.address.freeformAddress ?? "-"
    }
}
