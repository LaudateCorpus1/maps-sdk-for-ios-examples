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

enum BatchRouteType: Int {
    case BatchRouteTypeTravelMode
    case BatchRouteTypeRoute
    case BatchRouteTypeAvoids
}

class RoutingBatchRouteViewController: RoutingBaseViewController, TTBatchRouteVisistor, TTBatchRouteResponseDelegate, TTRouteDelegate {
    var batchRoute = TTBatchRoute()
    var type = BatchRouteType.BatchRouteTypeTravelMode
    var routeDesc = [BatchRouteType.BatchRouteTypeTravelMode: ["Travel by Car", "Travel by Truck", "Travel by Pedestrian"],
                     BatchRouteType.BatchRouteTypeRoute: ["Fastest route", "Shortest route", "Eco route"],
                     BatchRouteType.BatchRouteTypeAvoids: ["Avoid motorways", "Avoid ferries", "Avoid toll roads"]]

    override func setupInitialCameraPosition() {
        mapView.center(on: TTCoordinate.AMSTERDAM(), withZoom: 10)
    }

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Travel mode", "Route type", "Avoids"], selectedID: -1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        batchRoute = TTBatchRoute()
        batchRoute.delegate = self
        mapView.routeManager.delegate = self
    }

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        mapView.routeManager.removeAllRoutes()
        progress.show()
        etaView.hide()

        switch ID {
        case 2:
            performAvoids()
            type = BatchRouteType.BatchRouteTypeAvoids
        case 1:
            performRouteType()
            type = BatchRouteType.BatchRouteTypeRoute
        default:
            performTravelMode()
            type = BatchRouteType.BatchRouteTypeTravelMode
        }
    }

    // MARK: Examples

    func performTravelMode() {
        type = .BatchRouteTypeTravelMode
        let queryCar = TTRouteQueryBuilder.create(withDest: TTCoordinate.ROTTERDAM(), andOrig: TTCoordinate.AMSTERDAM())
            .withComputeBestOrder(true)
            .withTraffic(true)
            .withTravelMode(TTOptionTravelMode.car)
            .build()

        let queryTruck = TTRouteQueryBuilder.create(withDest: TTCoordinate.ROTTERDAM(), andOrig: TTCoordinate.AMSTERDAM())
            .withComputeBestOrder(true)
            .withTraffic(true)
            .withTravelMode(TTOptionTravelMode.truck)
            .build()

        let queryPedestrain = TTRouteQueryBuilder.create(withDest: TTCoordinate.ROTTERDAM(), andOrig: TTCoordinate.AMSTERDAM())
            .withComputeBestOrder(true)
            .withTraffic(true)
            .withTravelMode(TTOptionTravelMode.pedestrian)
            .build()
        let batchQuery = TTBatchRouteQueryBuilder.createRouteQuery(queryCar)
            .add(queryTruck)
            .add(queryPedestrain)
            .build()

        batchRoute = TTBatchRoute()
        batchRoute.delegate = self
        batchRoute.batchRoute(with: batchQuery)
    }

    func performRouteType() {
        type = .BatchRouteTypeRoute
        let queryFastest = TTRouteQueryBuilder.create(withDest: TTCoordinate.ROTTERDAM(), andOrig: TTCoordinate.AMSTERDAM())
            .withComputeBestOrder(true)
            .withTraffic(true)
            .withRouteType(TTOptionTypeRoute.fastest)
            .build()

        let queryShortest = TTRouteQueryBuilder.create(withDest: TTCoordinate.ROTTERDAM(), andOrig: TTCoordinate.AMSTERDAM())
            .withComputeBestOrder(true)
            .withTraffic(true)
            .withRouteType(TTOptionTypeRoute.shortest)
            .build()

        let queryEco = TTRouteQueryBuilder.create(withDest: TTCoordinate.ROTTERDAM(), andOrig: TTCoordinate.AMSTERDAM())
            .withComputeBestOrder(true)
            .withTraffic(true)
            .withRouteType(TTOptionTypeRoute.eco)
            .build()

        let batchQuery = TTBatchRouteQueryBuilder.createRouteQuery(queryFastest)
            .add(queryShortest)
            .add(queryEco)
            .build()

        batchRoute = TTBatchRoute()
        batchRoute.delegate = self
        batchRoute.batchRoute(with: batchQuery)
    }

    func performAvoids() {
        type = .BatchRouteTypeRoute
        let queryMotorways = TTRouteQueryBuilder.create(withDest: TTCoordinate.OSLO(), andOrig: TTCoordinate.AMSTERDAM())
            .withComputeBestOrder(true)
            .withTraffic(true)
            .withAvoidType(TTOptionTypeAvoid.motorways)
            .build()

        let queryFerries = TTRouteQueryBuilder.create(withDest: TTCoordinate.OSLO(), andOrig: TTCoordinate.AMSTERDAM())
            .withComputeBestOrder(true)
            .withTraffic(true)
            .withAvoidType(TTOptionTypeAvoid.ferries)
            .build()

        let queryTollRoads = TTRouteQueryBuilder.create(withDest: TTCoordinate.OSLO(), andOrig: TTCoordinate.AMSTERDAM())
            .withComputeBestOrder(true)
            .withTraffic(true)
            .withAvoidType(TTOptionTypeAvoid.tollRoads)
            .build()

        let batchQuery = TTBatchRouteQueryBuilder.createRouteQuery(queryMotorways)
            .add(queryFerries)
            .add(queryTollRoads)
            .build()

        batchRoute = TTBatchRoute()
        batchRoute.delegate = self
        batchRoute.batchRoute(with: batchQuery)
    }

    // MARK: TTBatchRouteResponseDelegate

    func batch(_: TTBatchRoute, completedWith response: TTBatchRouteResponse) {
        progress.hide()
        response.visit(self)
    }


    func batch(_: TTBatchRoute, failedWithError responseError: TTResponseError) {
        handleError(responseError)
    }


    // MARK: TTBatchRouteVisistor

    func visitRoute(_ response: TTRouteResult) {
        let mapRoute = TTMapRoute(coordinatesData: response.routes.first!,
                                  with: TTMapRouteStyle.defaultInactive(),
                                  imageStart: TTMapRoute.defaultImageDeparture(),
                                  imageEnd: TTMapRoute.defaultImageDestination())
        mapRoute.extraData = response.routes.first?.summary
        mapView.routeManager.add(mapRoute)
        progress.hide()
        displayRouteOverview()
    }


    // MARK: TTRouteDelegate

    func routeClicked(_ route: TTMapRoute) {
        for mapRoute in self.mapView.routeManager.routes {
            mapView.routeManager.update(mapRoute, style: TTMapRouteStyle.defaultInactive())
        }
        mapView.routeManager.update(route, style: TTMapRouteStyle.defaultActive())
        mapView.routeManager.bring(toFrontRoute: route)
        let desc = routeDesc[type]![mapView.routeManager.routes.index(of: route)!]
        updateEta(mapRoute: route, desc: desc)
    }

    // MARK: display ETA

    func updateEta(mapRoute: TTMapRoute, desc: String) {
        let summary = mapRoute.extraData as! TTSummary
        let eta = summary.arrivalTime

        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.hour, .minute])
        let components: NSDateComponents = calendar.dateComponents(unitFlags, from: eta) as NSDateComponents
        let dateInString = "\(components.hour):\(components.minute) \(desc)"
        etaView.update(eta: dateInString, metersDistance: UInt(summary.lengthInMetersValue))
    }
}
