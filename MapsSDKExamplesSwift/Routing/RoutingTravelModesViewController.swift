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

class RoutingTravelModesViewController: RoutingBaseViewController, TTRouteResponseDelegate {
    let routePlanner = TTRoute(key: Key.Routing)
    var routeStyle = TTMapRouteStyle.defaultActive()

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Car", "Truck", "Pedestrian"], selectedID: -1)
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
            displayPedestrianRoute()
        case 1:
            displayTruckRoute()
        default:
            displayCarRoute()
        }
    }

    // MARK: Examples

    func displayCarRoute() {
        self.routeStyle = TTMapRouteStyle.defaultActive()
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.AMSTERDAM(), andOrig: TTCoordinate.ROTTERDAM())
            .withTravelMode(.car)
            .build()
        routePlanner.plan(with: query)
    }

    func displayTruckRoute() {
        self.routeStyle = TTMapRouteStyle.defaultActive()
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.AMSTERDAM(), andOrig: TTCoordinate.ROTTERDAM())
            .withTravelMode(.truck)
            .build()
        routePlanner.plan(with: query)
    }

    func displayPedestrianRoute() {
        routeStyle = TTMapRouteStyleBuilder()
            .withLineCapType(TTLineCapType.round)
            .withWidth(0.3)
            .withFill(TTColor.BlueLight())
            .withOutlineColor(TTColor.BlackLight())
            .withDashArray([0.01, 2])
            .build()

        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.HAARLEMDC(),
                                               andOrig: TTCoordinate.HAARLEMZW())
            .withTravelMode(.pedestrian)
            .build()
        routePlanner.plan(with: query)
    }

    // MARK: TTRouteResponseDelegate

    func route(_: TTRoute, completedWith result: TTRouteResult) {
        guard let plannedRoute = result.routes.first else {
            return
        }
        let mapRoute = TTMapRoute(coordinatesData: plannedRoute,
                                  with: self.routeStyle,
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
