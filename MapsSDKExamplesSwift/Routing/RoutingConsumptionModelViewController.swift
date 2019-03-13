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

import UIKit
import MapsSDKExamplesCommon
import MapsSDKExamplesVC
import TomTomOnlineSDKRouting
import TomTomOnlineSDKMaps

class RoutingConsumptionModelViewController: RoutingBaseViewController, TTRouteResponseDelegate, TTRouteDelegate {

    let routePlanner = TTRoute()
    var style = ETAView.ETAViewStyle.consumptionKWh
    
    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Combustion", "Electric"], selectedID: -1)
    }
    
    override func setupCenterOnWillHappen() {
        mapView.center(on: TTCoordinate.AMSTERDAM(), withZoom: 10)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        routePlanner.delegate = self
        mapView.routeManager.delegate = self
    }
    
    //MARK: OptionsViewDelegate
    
    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        mapView.routeManager.removeAllRoutes()
        progress.show()
        switch ID {
        case 1:
            displayElectricRoute()
        default:
            displayCombustionRoute()
        }
    }
    
    //MARK: Examples
    
    func displayCombustionRoute() {
        style = ETAView.ETAViewStyle.consumptionLiters
        var speedConsumptionInLiters: [TTSpeedConsumption] = [TTSpeedConsumptionMake(10, 6.5),
                                                              TTSpeedConsumptionMake(30, 7.0),
                                                              TTSpeedConsumptionMake(50, 8.0),
                                                              TTSpeedConsumptionMake(70, 8.4),
                                                              TTSpeedConsumptionMake(90, 7.7),
                                                              TTSpeedConsumptionMake(120, 7.5),
                                                              TTSpeedConsumptionMake(150, 9.0)]
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.UTRECHT(), andOrig: TTCoordinate.AMSTERDAM())
            .withMaxAlternatives(2)
            .withVehicleWeight(1600)
            .withCurrentFuel(inLiters: 50.0)
            .withCurrentAuxiliaryPower(inLitersPerHour: 0.2)
            .withFuelEnergyDensity(inMJoulesPerLiter: 34.2)
            .withAccelerationEfficiency(0.33)
            .withDecelerationEfficiency(0.33)
            .withUphillEfficiency(0.33)
            .withDownhillEfficiency(0.33)
            .withVehicleEngineType(.combustion)
            .withSpeedConsumption(inLitersPairs: &speedConsumptionInLiters, count: UInt(speedConsumptionInLiters.count))
            .build()
        routePlanner.plan(with: query)
    }
    
    func displayElectricRoute() {
        style = ETAView.ETAViewStyle.consumptionKWh
        var speedConsumptionInkWh: [TTSpeedConsumption] = [TTSpeedConsumptionMake(10, 5.0),
                                                           TTSpeedConsumptionMake(30, 10.0),
                                                           TTSpeedConsumptionMake(50, 15.0),
                                                           TTSpeedConsumptionMake(70, 20.0),
                                                           TTSpeedConsumptionMake(90, 25.0),
                                                           TTSpeedConsumptionMake(120, 30.0)]
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.UTRECHT(), andOrig: TTCoordinate.AMSTERDAM())
            .withMaxAlternatives(2)
            .withVehicleWeight(1600)
            .withCurrentChargeInkWh(43)
            .withMaxChargeInkWh(85)
            .withAuxiliaryPowerInkW(1.7)
            .withAccelerationEfficiency(0.33)
            .withDecelerationEfficiency(0.33)
            .withUphillEfficiency(0.33)
            .withDownhillEfficiency(0.33)
            .withVehicleEngineType(.electric)
            .withSpeedConsumptionInkWhPairs(&speedConsumptionInkWh, count: UInt(speedConsumptionInkWh.count))
            .build()
        routePlanner.plan(with: query)
    }
    
    //MARK: TTRouteResponseDelegate
    
    func route(_ route: TTRoute, completedWith result: TTRouteResult) {
        var isActive = true
        var activeRoute: TTMapRoute?
        for plannedRoute in result.routes {
            let mapRoute = TTMapRoute(coordinatesData: plannedRoute,
                                      with: isActive ? TTMapRouteStyle.defaultActive() : TTMapRouteStyle.defaultInactive(),
                                      imageStart: TTMapRoute.defaultImageDeparture(),
                                      imageEnd: TTMapRoute.defaultImageDestination())
            mapView.routeManager.add(mapRoute)
            mapRoute.extraData = plannedRoute.summary
            if isActive {
                activeRoute = mapRoute
                etaView.show(summary: plannedRoute.summary, style: style)
            }
            isActive = false
        }
        mapView.routeManager.bring(toFrontRoute: activeRoute!)
        displayRouteOverview()
        progress.hide()
    }
    
    func route(_ route: TTRoute, completedWith responseError: TTResponseError) {
        handleError(responseError)
    }
    
    //MARK: TTRouteDelegate
    
    func routeClicked(_ route: TTMapRoute) {
        for mapRoute in self.mapView.routeManager.routes {
            mapView.routeManager.update(mapRoute, style: TTMapRouteStyle.defaultInactive())
        }
        mapView.routeManager.update(route, style: TTMapRouteStyle.defaultActive())
        mapView.routeManager.bring(toFrontRoute: route)
        etaView.show(summary: route.extraData as! TTSummary, style: style)
    }

}
