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
import TomTomOnlineSDKSearch
import UIKit

class SearchAlongTheRouteViewController: RoutingBaseViewController, TTRouteResponseDelegate, TTAlongRouteSearchDelegate {
    let routePlanner = TTRoute()
    let alongRouteSearch = TTAlongRouteSearch()
    var mapRoute: TTMapRoute!

    override func setupCenterOnWillHappen() {
        if mapView.routeManager.routes.isEmpty {
            super.setupCenterOnWillHappen()
        } else {
            displayRouteOverview()
        }
    }

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Car repair", "Gas stations", "EV stations"], selectedID: -1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        routePlanner.delegate = self
        alongRouteSearch.delegate = self

        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.HAARLEM(), andOrig: TTCoordinate.AMSTERDAM())
            .build()
        routePlanner.plan(with: query)
        progress.show()
    }

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        progress.show()
        switch ID {
        case 2:
            searchForEVStations()
        case 1:
            searchForGasStations()
        default:
            searchForCarRepair()
        }
    }

    // MARK: Examples

    func searchForCarRepair() {
        let query = TTAlongRouteSearchQueryBuilder(term: "REPAIR_FACILITY", withRoute: mapRoute, withMaxDetourTime: 900)
            .withLimit(10)
            .build()
        alongRouteSearch.search(with: query)
    }

    func searchForGasStations() {
        let query = TTAlongRouteSearchQueryBuilder(term: "PETROL_STATION", withRoute: mapRoute, withMaxDetourTime: 900)
            .withLimit(10)
            .build()
        alongRouteSearch.search(with: query)
    }

    func searchForEVStations() {
        let query = TTAlongRouteSearchQueryBuilder(term: "ELECTRIC_VEHICLE_STATION", withRoute: mapRoute, withMaxDetourTime: 900)
            .withLimit(10)
            .build()
        alongRouteSearch.search(with: query)
    }

    // MARK: TTRouteResponseDelegate

    func route(_: TTRoute, completedWith result: TTRouteResult) {
        guard let plannedRoute = result.routes.first else {
            return
        }
        mapRoute = TTMapRoute(coordinatesData: plannedRoute,
                              with: TTMapRouteStyle.defaultActive(),
                              imageStart: TTMapRoute.defaultImageDeparture(),
                              imageEnd: TTMapRoute.defaultImageDestination())
        mapView.routeManager.add(mapRoute)
        mapView.routeManager.bring(toFrontRoute: mapRoute)
        displayRouteOverview()
        progress.hide()
    }

    func route(_: TTRoute, completedWith responseError: TTResponseError) {
        handleError(responseError)
    }

    // MARK: TTAlongRouteSearchDelegate

    func search(_: TTAlongRouteSearch, completedWith response: TTAlongRouteSearchResponse) {
        progress.hide()
        mapView.annotationManager.removeAllAnnotations()
        for result in response.results {
            let annotation = TTAnnotation(coordinate: result.position)
            annotation.selectable = false
            mapView.annotationManager.add(annotation)
        }
    }

    func search(_: TTAlongRouteSearch, failedWithError error: TTResponseError) {
        handleError(error)
    }
}
