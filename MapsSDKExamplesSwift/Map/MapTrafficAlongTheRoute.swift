/**
 * Copyright (c) 2020 TomTom N.V. All rights reserved.
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

class MapTrafficAlongTheRoute: RoutingBaseViewController, TTRouteResponseDelegate {
    let routePlanner = TTRoute(key: Key.Routing)

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["London", "Los Angeles"], selectedID: -1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        routePlanner.delegate = self
    }

    func trafficStyleMapping() -> [TTRouteTrafficStyle] {
        [UIColor(red: 0.8, green: 0.6, blue: 0, alpha: 1),
         UIColor(red: 1, green: 1, blue: 0, alpha: 1),
         UIColor(red: 1, green: 0.6, blue: 0, alpha: 1),
         UIColor(red: 1, green: 0.2, blue: 0, alpha: 1),
         UIColor(red: 0.6, green: 0.2, blue: 0, alpha: 1),
         UIColor(red: 1, green: 1, blue: 1, alpha: 1)]
            .map { TTMapRouteStyleLayerBuilder()
                .withColor($0)
                .build()
            }
            .map { TTRouteTrafficStyle(routeStyle: [$0]) }
    }


    override func setupInitialCameraPosition() {
        mapView.center(on: TTCoordinate.HEATHROW_AIRPORT(), withZoom: 5)
    }

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        mapView.routeManager.removeAllRoutes()
        progress.show()
        switch ID {
        case 1:
            displayLongRoute()
        default:
            displayShortRute()
        }
    }

    // MARK: Examples

    func displayShortRute() {
        var wayPoints = [TTCoordinate.TOWER_OF_LONDON(), TTCoordinate.THE_NATIONAL_GALLERY()]
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.HEATHROW_AIRPORT(), andOrig: TTCoordinate.LONDON_CITY_AIRPORT())
            .withWayPoints(&wayPoints, count: UInt(wayPoints.count))
            .withSectionType(.traffic)
            .withTraffic(false)
            .build()
        routePlanner.plan(with: query)
    }

    func displayLongRoute() {
        var wayPoints = [TTCoordinate.DOWN_TOWN_LOS_ANGELES(), TTCoordinate.BEVERLY_HILS(), TTCoordinate.SANTA_MONICA()]
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.ONTARIO_INTERNATIONAL_AIRPORT(), andOrig: TTCoordinate.LOS_ANGELES_INTERNATIONAL_AIRPORT())
            .withWayPoints(&wayPoints, count: UInt(wayPoints.count))
            .withSectionType(.traffic)
            .withTraffic(false)
            .build()
        routePlanner.plan(with: query)
    }

    // MARK: TTRouteResponseDelegate

    func route(_: TTRoute, completedWith result: TTRouteResult) {
        guard let plannedRoute = result.routes.first else {
            return
        }

        let styleMapping = trafficStyleMapping()
        var styling = [TTRouteTrafficStyle: [TTTrafficData]]()
        plannedRoute.sections.forEach { section in
            let density = section.magnitudeOfDelayValue >= 0 ? section.magnitudeOfDelayValue : 5
            let style = styleMapping[density]
            var array = styling[style] ?? []
            array.append(TTTrafficData(startPointIndex: section.startPointIndexValue, andEndPointIndex: section.endPointIndexValue))
            styling[style] = array
        }

        let mapRoute = TTMapRoute(coordinatesData: plannedRoute,
                                  with: TTMapRouteStyle.defaultActive(),
                                  imageStart: TTMapRoute.defaultImageDeparture(),
                                  imageEnd: TTMapRoute.defaultImageDestination())
        mapView.routeManager.add(mapRoute)
        mapView.routeManager.showTraffic(on: mapRoute, withStyling: styling)
        displayRouteOverview()
        progress.hide()
    }

    func route(_: TTRoute, completedWith responseError: TTResponseError) {
        handleError(responseError)
    }
}
