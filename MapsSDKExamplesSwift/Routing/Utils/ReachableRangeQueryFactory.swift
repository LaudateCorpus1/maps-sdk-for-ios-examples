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

import TomTomOnlineSDKRouting
import MapsSDKExamplesCommon

class ReachableRangeQueryFactory: NSObject {

    func createReachableRangeQueryForElectric() -> TTReachableRangeQuery {
        var speedConsumption = [TTSpeedConsumptionMake(50, 6.3)]
        let query = TTReachableRangeQueryBuilder.create(withCenterLocation: TTCoordinate.AMSTERDAM())
            .withSpeedConsumptionInkWhPairs(&speedConsumption, count: UInt(speedConsumption.count))
            .withVehicleWeight(1600)
            .withCurrentChargeInkWh(43)
            .withMaxChargeInkWh(85)
            .withAuxiliaryPowerInkW(1.7)
            .withAccelerationEfficiency(0.33)
            .withDecelerationEfficiency(0.33)
            .withUphillEfficiency(0.33)
            .withDownhillEfficiency(0.33)
            .withVehicleEngineType(.electric)
            .withEnergyBudget(inKWh: 5)
            .build()
        return query
    }
    
    func createReachableRangeQueryForElectricLimitTo2Hours() -> TTReachableRangeQuery {
        var speedConsumption = [TTSpeedConsumptionMake(50, 6.3)]
        let query = TTReachableRangeQueryBuilder.create(withCenterLocation: TTCoordinate.AMSTERDAM())
            .withSpeedConsumptionInkWhPairs(&speedConsumption, count: UInt(speedConsumption.count))
            .withVehicleWeight(1600)
            .withCurrentChargeInkWh(43)
            .withMaxChargeInkWh(85)
            .withAuxiliaryPowerInkW(1.7)
            .withAccelerationEfficiency(0.33)
            .withDecelerationEfficiency(0.33)
            .withUphillEfficiency(0.33)
            .withDownhillEfficiency(0.33)
            .withVehicleEngineType(.electric)
            .withTimeBudget(inSeconds: 2 * 60 * 60)
            .build()
        return query
    }
    
    func createReachableRangeQueryForCombustion() -> TTReachableRangeQuery {
        var speedConsumption = [TTSpeedConsumptionMake(50, 6.3)]
        let query = TTReachableRangeQueryBuilder.create(withCenterLocation: TTCoordinate.AMSTERDAM())
            .withSpeedConsumption(inLitersPairs: &speedConsumption, count: UInt(speedConsumption.count))
            .withVehicleWeight(1600)
            .withCurrentFuel(inLiters: 43)
            .withFuelEnergyDensity(inMJoulesPerLiter: 34.2)
            .withCurrentAuxiliaryPower(inLitersPerHour: 1.7)
            .withAccelerationEfficiency(0.33)
            .withDecelerationEfficiency(0.33)
            .withUphillEfficiency(0.33)
            .withDownhillEfficiency(0.33)
            .withVehicleEngineType(.combustion)
            .withFuelBudget(inLiters: 5)
            .build()
        return query
    }
}
