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

@objc class ShortRangeConsumption: NSObject, ElectricVehicleConsumption {
    var maxChargeInkWh: Double = 50

    var currentChargeInkWh: Double = 20

    var auxiliaryPowerInkW: Double = 0.2

    var speedConsumptionInKWhPerHundredKm: [NSNumber: NSNumber] = [77: 32, 18.01: 10.87]
}

@objc class LongRangeConsumption: NSObject, ElectricVehicleConsumption {
    var maxChargeInkWh: Double = 80

    var currentChargeInkWh: Double = 20

    var auxiliaryPowerInkW: Double = 0.2

    var speedConsumptionInKWhPerHundredKm: [NSNumber: NSNumber] = [77: 32, 18.01: 10.87]
}

@objc public class ElectricVehicle: NSObject, ElectricVehicleProtocol {
    @objc public var vehicleConsumption: ElectricVehicleConsumption

    init(vehicleConsumption: ElectricVehicleConsumption) {
        self.vehicleConsumption = vehicleConsumption
    }

    @objc public static var shortRange: ElectricVehicle = .init(vehicleConsumption: ShortRangeConsumption())
    @objc public static var longRange: ElectricVehicle = .init(vehicleConsumption: LongRangeConsumption())
}

@objc public class ShortRangeChargingSchema: NSObject, ChargingProtocol {
    public var minChargeAtDestinationInkWh: Double = 2

    public var minChargeAtChargingStopsInkWh: Double = 4

    public var chargingModes: [ChargingMode] = [.init(chargingConnections: [.init(facilityType: .charge380To480V3PhaseAt32A, plugType: .IEC62196TypeTwoOutlet)],
                                                      chargingCurves: [.init(chargeInKwh: 6, timeToCharge: 360), .init(chargeInKwh: 50, timeToCharge: 4680)])]
}

@objc public class LongRangeChargingSchema: NSObject, ChargingProtocol {
    public var minChargeAtDestinationInkWh: Double = 4

    public var minChargeAtChargingStopsInkWh: Double = 8

    public var chargingModes: [ChargingMode] = [.init(chargingConnections: [.init(facilityType: .charge380To480V3PhaseAt32A, plugType: .IEC62196TypeTwoOutlet)],
                                                      chargingCurves: [.init(chargeInKwh: 6, timeToCharge: 360), .init(chargeInKwh: 80, timeToCharge: 6680)])]
}
