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
import TomTomOnlineSDKRouting

@objc public class ChargeStationAnnotation: TTAnnotation {
    @objc public let info: ChargingInformationAtEndOfLeg

    @objc public init(info: ChargingInformationAtEndOfLeg, coordinate: CLLocationCoordinate2D) {
        self.info = info
        let image = TTAnnotationImage.createPNG(withName: "ic_map_poi_073")!
        super.init(coordinate: coordinate, annotationImage: image, anchor: .bottom, type: .focal)
    }
}
