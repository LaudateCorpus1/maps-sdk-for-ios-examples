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

class RoutingSupportingPointsViewController: RoutingBaseViewController, TTRouteResponseDelegate, TTRouteDelegate {

    let routePlanner = TTRoute()
    
    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["0 m", "10 km"], selectedID: -1)
    }
    
    override func setupCenterOnWillHappen() {
        mapView.center(on: TTCoordinate.PORTUGAL_NOVA(), withZoom: 10)
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
            displayDeviation10kmRoute()
        default:
            displayDeviation0mRoute()
        }
    }
    
    //MARK: Examples
    
    func displayDeviation0mRoute() {
        var supprotingPoints = getSupprotingPoints()
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.PORTUGAL_COIMBRA(), andOrig: TTCoordinate.PORTUGAL_NOVA())
            .withMaxAlternatives(1)
            .withMinDeviationTime(0)
            .withSupportingPoints(&supprotingPoints, count: UInt(supprotingPoints.count))
            .withMinDeviationDistance(0)
            .build()
        routePlanner.plan(with: query)
    }
    
    func displayDeviation10kmRoute() {
        var supprotingPoints = getSupprotingPoints()
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.PORTUGAL_COIMBRA(), andOrig: TTCoordinate.PORTUGAL_NOVA())
            .withMaxAlternatives(1)
            .withMinDeviationTime(0)
            .withSupportingPoints(&supprotingPoints, count: UInt(supprotingPoints.count))
            .withMinDeviationDistance(10000)
            .build()
        routePlanner.plan(with: query)
    }
    
    private func getSupprotingPoints() -> [CLLocationCoordinate2D] {
        return [
            CLLocationCoordinate2DMake(40.10995732392718, -8.501433134078981),
            CLLocationCoordinate2DMake(40.11115121590874, -8.500000834465029),
            CLLocationCoordinate2DMake(40.11089684892725, -8.497683405876161),
            CLLocationCoordinate2DMake(40.11192251642396, -8.498423695564272),
            CLLocationCoordinate2DMake(40.209408, -8.423741)
        ]
    }
    
    //MARK: TTRouteResponseDelegate
    
    func route(_ route: TTRoute, completedWith result: TTRouteResult) {
        var isActive = true
        for plannedRoute in result.routes {
            let mapRoute = TTMapRoute(coordinatesData: plannedRoute,
                                      imageStart: TTMapRoute.defaultImageDeparture(),
                                      imageEnd: TTMapRoute.defaultImageDestination())
            mapView.routeManager.add(mapRoute)
            mapRoute.isActive = isActive
            mapRoute.extraData = plannedRoute.summary
            if isActive {
                etaView.show(summary: plannedRoute.summary, style: .plain)
            }
            isActive = false
        }
        displayRouteOverview()
        progress.hide()
    }
    
    func route(_ route: TTRoute, completedWith responseError: TTResponseError) {
        toast.toast(message: "error " + (responseError.userInfo["description"] as! String))
        progress.hide()
        optionsView.deselectAll()
    }
    
    //MARK: TTRouteDelegate
    
    func routeClicked(_ route: TTMapRoute) {
        for mapRoute in self.mapView.routeManager.routes {
            mapRoute.isActive = route == mapRoute
        }
        etaView.show(summary: route.extraData as! TTSummary, style: .plain)
    }

}
