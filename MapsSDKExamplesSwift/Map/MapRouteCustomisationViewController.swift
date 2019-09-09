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

class MapRouteCustomisationViewController: RoutingBaseViewController, TTRouteResponseDelegate {
    let routePlanner = TTRoute()
    var routeStyle = TTMapRouteStyleBuilder().build()
    var iconStart = TTMapRoute.defaultImageDeparture()
    var iconEnd = TTMapRoute.defaultImageDestination()
    var isSegmeneted = false

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Basic", "Custom", "Segmented"], selectedID: -1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        routePlanner.delegate = self
    }

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        mapView.routeManager.removeAllRoutes()
        progress.show()
        isSegmeneted = false
        switch ID {
        case 2:
            isSegmeneted = true
            displaySegmentedRoute()
        case 1:
            displayCustomRoute()
        default:
            displayBasicRoute()
        }
    }

    // MARK: Examples

    func displayBasicRoute() {
        routeStyle = TTMapRouteStyle.defaultActive()
        iconStart = TTMapRoute.defaultImageDeparture()
        iconEnd = TTMapRoute.defaultImageDestination()
        planRoute()
    }

    func displayCustomRoute() {
        routeStyle = TTMapRouteStyleBuilder()
            .withWidth(2.0)
            .withFill(.black)
            .withOutlineColor(.red)
            .build()
        iconStart = UIImage(named: "Start")!
        iconEnd = UIImage(named: "End")!
        planRoute()
    }

    func displaySegmentedRoute() {
        planSegmentedRoute()
    }

    private func planRoute() {
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.AMSTERDAM(), andOrig: TTCoordinate.ROTTERDAM())
            .withTravelMode(.car)
            .build()
        routePlanner.plan(with: query)
    }

    private func planSegmentedRoute() {
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.AMSTERDAM(), andOrig: TTCoordinate.LODZ())
            .withSectionType(TTSectionType.country)
            .withTraffic(false)
            .build()
        routePlanner.plan(with: query)
    }

    // MARK: TTRouteResponseDelegate

    func route(_: TTRoute, completedWith result: TTRouteResult) {
        guard let plannedRoute = result.routes.first else {
            return
        }
        if isSegmeneted {
            routeSegmetedPlanned(plannedRoute: plannedRoute)
        } else {
            routePlanned(plannedRoute: plannedRoute)
        }
    }

    func arrayOfCoordiantes(plannedRoute: TTFullRoute, start: Int, end: Int) -> [CLLocationCoordinate2D] {
        let section = plannedRoute.coordinatesData()[start ..< end]

        var coordinateArray: [CLLocationCoordinate2D] = []
        for valueCoordiantes in section {
            var locationCoord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
            if #available(iOS 11.0, *) {
                valueCoordiantes.getValue(&locationCoord, size: MemoryLayout<CLLocationCoordinate2D>.size)
            } else {
                valueCoordiantes.getValue(&locationCoord)
            }
            coordinateArray.append(locationCoord)
        }
        return coordinateArray
    }

    func routeSegmetedPlanned(plannedRoute: TTFullRoute) {

        // Section 1
        let routeStyle1 = TTMapRouteStyleBuilder()
            .withWidth(1.0)
            .withFill(.black)
            .withOutlineColor(.black)
            .build()

        let startPoint1 = plannedRoute.sections[0].startPointIndexValue
        let endPoint1 = plannedRoute.sections[0].endPointIndexValue

        var coordinatesSection1 = arrayOfCoordiantes(plannedRoute: plannedRoute, start: startPoint1, end: endPoint1)
        let mapRoute = TTMapRoute(coordinates: &coordinatesSection1, count: UInt(coordinatesSection1.count), with: routeStyle1,
                                  imageStart: iconStart, imageEnd: iconEnd)

        // Section 2
        let routeStyle2 = TTMapRouteStyleBuilder()
            .withWidth(1.0)
            .withFill(.blue)
            .withOutlineColor(.blue)
            .build()

        let startPoint2 = plannedRoute.sections[1].startPointIndexValue
        let endPoint2 = plannedRoute.sections[1].endPointIndexValue
        var coordinatesSection2 = arrayOfCoordiantes(plannedRoute: plannedRoute, start: startPoint2, end: endPoint2)
        mapRoute.addCoordinates(&coordinatesSection2, count: UInt(coordinatesSection2.count), with: routeStyle2)

        // Section 3
        let routeStyle3 = TTMapRouteStyleBuilder()
            .withWidth(1.0)
            .withFill(.red)
            .withOutlineColor(.red)
            .build()

        let startPoint3 = plannedRoute.sections[2].startPointIndexValue
        let endPoint3 = plannedRoute.sections[2].endPointIndexValue
        var coordinatesSection3 = arrayOfCoordiantes(plannedRoute: plannedRoute, start: startPoint3, end: endPoint3)
        mapRoute.addCoordinates(&coordinatesSection3, count: UInt(coordinatesSection3.count), with: routeStyle3)

        mapView.routeManager.add(mapRoute)
        displayRoute(plannedRoute: plannedRoute)
    }

    func routePlanned(plannedRoute: TTFullRoute) {
        let mapRoute = TTMapRoute(coordinatesData: plannedRoute, with: routeStyle,
                                  imageStart: iconStart, imageEnd: iconEnd)
        mapView.routeManager.add(mapRoute)
        displayRoute(plannedRoute: plannedRoute)
    }

    func displayRoute(plannedRoute: TTFullRoute) {
        etaView.show(summary: plannedRoute.summary, style: .plain)
        displayRouteOverview()
        progress.hide()
    }

    func route(_: TTRoute, completedWith responseError: TTResponseError) {
        handleError(responseError)
    }
}
