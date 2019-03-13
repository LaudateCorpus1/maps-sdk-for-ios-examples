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

class RoutingRouteAvoidsViewController: RoutingBaseViewController, TTRouteResponseDelegate {

    let routePlanner = TTRoute()
    
    override func setupCenterOnWillHappen() {
        mapView.center(on: TTCoordinate.NORTH_SEA(), withZoom: 4)
    }
    
    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Motorways", "Toll roads", "Ferries"], selectedID: -1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        routePlanner.delegate = self
    }
    
    //MARK: OptionsViewDelegate
    
    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        mapView.routeManager.removeAllRoutes()
        progress.show()
        switch ID {
        case 2:
            displayAvoidFerriesRoute()
        case 1:
            displayAvoidTollRoadsRoute()
        default:
            displayAvoidMotorwaysRoute()
        }
    }
    
    //MARK: Examples
    
    func displayAvoidMotorwaysRoute() {
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.OSLO(), andOrig: TTCoordinate.AMSTERDAM())
            .withAvoidType(.motorways)
            .build()
        routePlanner.plan(with: query)
    }
    
    func displayAvoidTollRoadsRoute() {
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.OSLO(), andOrig: TTCoordinate.AMSTERDAM())
            .withAvoidType(.tollRoads)
            .build()
        routePlanner.plan(with: query)
    }
    
    func displayAvoidFerriesRoute() {
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.OSLO(), andOrig: TTCoordinate.AMSTERDAM())
            .withAvoidType(.ferries)
            .build()
        routePlanner.plan(with: query)
    }
    
    //MARK: TTRouteResponseDelegate
    
    func route(_ route: TTRoute, completedWith result: TTRouteResult) {
        guard let plannedRoute = result.routes.first else {
            return
        }
        let mapRoute = TTMapRoute(coordinatesData: plannedRoute,
                                  with: TTMapRouteStyle.defaultActive(),
                                  imageStart: TTMapRoute.defaultImageDeparture(),
                                  imageEnd: TTMapRoute.defaultImageDestination())
        mapView.routeManager.add(mapRoute)
        mapView.routeManager.bring(toFrontRoute: mapRoute)
        etaView.show(summary: plannedRoute.summary, style: .plain)
        displayRouteOverview()
        progress.hide()
    }
    
    func route(_ route: TTRoute, completedWith responseError: TTResponseError) {
        handleError(responseError)
    }

}
