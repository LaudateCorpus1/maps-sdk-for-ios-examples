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

class RoutingRouteTypesViewController: RoutingBaseViewController, TTRouteResponseDelegate {
    let routePlanner = TTRoute(key: Key.Routing)

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Fastest", "Shortest", "Eco"], selectedID: -1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        routePlanner.delegate = self
    }

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        mapView.routeManager.removeAllRoutes()
        progress.show()
        switch ID {
        case 2:
            displayEcoRoute()
        case 1:
            displayShortestRoute()
        default:
            displayFastestRoute()
        }
    }

    // MARK: Examples

    func displayFastestRoute() {
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.AMSTERDAM(), andOrig: TTCoordinate.ROTTERDAM())
            .withRouteType(.fastest)
            .build()
        routePlanner.plan(with: query)
    }

    func displayShortestRoute() {
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.AMSTERDAM(), andOrig: TTCoordinate.ROTTERDAM())
            .withRouteType(.shortest)
            .build()
        routePlanner.plan(with: query)
    }

    func displayEcoRoute() {
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.AMSTERDAM(), andOrig: TTCoordinate.ROTTERDAM())
            .withRouteType(.eco)
            .build()
        routePlanner.plan(with: query)
    }

    // MARK: TTRouteResponseDelegate

    func route(_: TTRoute, completedWith result: TTRouteResult) {
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

    func route(_: TTRoute, completedWith responseError: TTResponseError) {
        handleError(responseError)
    }
}
