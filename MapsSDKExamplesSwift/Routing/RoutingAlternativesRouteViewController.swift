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

class RoutingAlternativesRouteViewController: RoutingBaseViewController, TTRouteResponseDelegate, TTRouteDelegate {

    let routePlanner = TTRoute()
    
    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["1", "3", "5"], selectedID: -1)
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
        case 2:
            displayRouteWith5Alternative()
        case 1:
            displayRouteWith3Alternative()
        default:
            displayRouteWith1Alternative()
        }
    }
    
    //MARK: Examples
    
    func displayRouteWith1Alternative() {
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.AMSTERDAM(), andOrig: TTCoordinate.ROTTERDAM())
            .withMaxAlternatives(1)
            .build()
        routePlanner.plan(with: query)
    }
    
    func displayRouteWith3Alternative() {
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.AMSTERDAM(), andOrig: TTCoordinate.ROTTERDAM())
            .withMaxAlternatives(3)
            .build()
        routePlanner.plan(with: query)
    }
    
    func displayRouteWith5Alternative() {
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.AMSTERDAM(), andOrig: TTCoordinate.ROTTERDAM())
            .withMaxAlternatives(5)
            .build()
        routePlanner.plan(with: query)
    }
    
    //MARK: TTRouteResponseDelegate
    
    func route(_ route: TTRoute, completedWith result: TTRouteResult) {
        var activeRoute: TTMapRoute?
        for planedRoute in result.routes {
            if activeRoute == nil {
                let mapRoute = TTMapRoute(coordinatesData: planedRoute,
                                          with: TTMapRouteStyle.defaultActive(),
                                          imageStart: TTMapRoute.defaultImageDeparture(),
                                          imageEnd: TTMapRoute.defaultImageDestination())
                mapView.routeManager.add(mapRoute)
                mapRoute.extraData = planedRoute.summary
                activeRoute = mapRoute
                etaView.show(summary: planedRoute.summary, style: .plain)
            } else {
                let mapRoute = TTMapRoute(coordinatesData: planedRoute,
                                          with: TTMapRouteStyle.defaultInactive(),
                                          imageStart: TTMapRoute.defaultImageDeparture(),
                                          imageEnd: TTMapRoute.defaultImageDestination())
                mapView.routeManager.add(mapRoute)
                mapRoute.extraData = planedRoute.summary
            }
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
        etaView.show(summary: route.extraData as! TTSummary, style: .plain)
    }

}
