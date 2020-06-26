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

import MapsSDKExamplesCommon
import MapsSDKExamplesVC
import TomTomOnlineSDKMaps
import TomTomOnlineSDKRouting
import UIKit

class RoutingSupportingPointsViewController: RoutingBaseViewController, TTRouteResponseDelegate, TTRouteDelegate {
    let routePlanner = TTRoute(key: Key.Routing)

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["0 m", "10 km"], selectedID: -1)
    }

    override func setupInitialCameraPosition() {
        mapView.center(on: TTCoordinate.PORTUGAL_NOVA(), withZoom: 10)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        routePlanner.delegate = self
        mapView.routeManager.delegate = self
    }

    // MARK: OptionsViewDelegate

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

    // MARK: Examples

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
            CLLocationCoordinate2DMake(40.209408, -8.423741),
        ]
    }

    // MARK: TTRouteResponseDelegate

    func route(_: TTRoute, completedWith result: TTRouteResult) {
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
                etaView.show(summary: plannedRoute.summary, style: .plain)
            }
            isActive = false
        }
        mapView.routeManager.bring(toFrontRoute: activeRoute!)
        displayRouteOverview()
        progress.hide()
    }

    func route(_: TTRoute, completedWith responseError: TTResponseError) {
        handleError(responseError)
    }

    // MARK: TTRouteDelegate

    func routeClicked(_ route: TTMapRoute) {
        for mapRoute in self.mapView.routeManager.routes {
            mapView.routeManager.update(mapRoute, style: TTMapRouteStyle.defaultInactive())
        }
        mapView.routeManager.update(route, style: TTMapRouteStyle.defaultActive())
        mapView.routeManager.bring(toFrontRoute: route)
        etaView.show(summary: route.extraData as! TTSummary, style: .plain)
    }
}
