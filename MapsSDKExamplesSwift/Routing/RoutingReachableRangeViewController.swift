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

import UIKit
import MapsSDKExamplesCommon
import MapsSDKExamplesVC
import TomTomOnlineSDKRouting
import TomTomOnlineSDKMaps

class RoutingReachableRangeViewController: RoutingBaseViewController, TTReachableRangeDelegate {

    let reachabeRange = TTReachableRange()
    
    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Combustion", "Electric", "Time - 2h"], selectedID: -1)
    }
    
    override func setupCenterOnWillHappen() {
        mapView.center(on: TTCoordinate.AMSTERDAM(), withZoom: 10)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reachabeRange.delegate = self
    }
    
    //MARK: OptionsViewDelegate
    
    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        mapView.annotationManager.removeAllOverlays()
        progress.show()
        switch ID {
        case 2:
            displayReachableRangeIn2hTime()
        case 1:
            displayReachableRangeForElectric()
        default:
            displayReachableRangeForCombustion()
        }
    }
    
    //MARK: Examples
    
    func displayReachableRangeForCombustion() {
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
        reachabeRange.find(with: query)
    }
    
    func displayReachableRangeForElectric() {
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
        reachabeRange.find(with: query)
    }
    
    func displayReachableRangeIn2hTime() {
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
        reachabeRange.find(with: query)
    }
    
    //MARK: TTReachableRangeDelegate
    
    func reachableRange(_ range: TTReachableRange, completedWithResult response: TTReachableRangeResponse) {
        progress.hide()
        var coordinates: [CLLocationCoordinate2D] = []
        for i in 0..<response.result.boundriesCount {
            coordinates.append(response.result.boundry(at: i))
        }
        
        let polygon = TTPolygon(coordinates: &coordinates, count: UInt(coordinates.count), opacity: 1, color: TTColor.RedSemiTransparent(), colorOutline: TTColor.RedSemiTransparent())
        mapView.annotationManager.add(polygon)
        mapView.zoom(to: polygon)
    }
    
    func reachableRange(_ range: TTReachableRange, completedWith responseError: TTResponseError) {
        toast.toast(message: "error " + (responseError.userInfo["description"] as! String))
        progress.hide()
        optionsView.deselectAll()
    }

}
