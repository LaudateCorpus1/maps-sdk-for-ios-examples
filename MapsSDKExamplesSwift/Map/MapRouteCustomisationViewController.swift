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

class MapRouteCustomisationViewController: RoutingBaseViewController, TTRouteResponseDelegate {

    let routePlanner = TTRoute()
    var routeStyle = TTMapRouteStyleBuilder().build()
    var iconStart = TTMapRoute.defaultImageDeparture()
    var iconEnd = TTMapRoute.defaultImageDestination()
    
    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Basic", "Custom"], selectedID: -1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        routePlanner.delegate = self
    }
    
    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        mapView.routeManager.removeAllRoutes()
        progress.show()
        switch ID {
        case 1:
            displayCustomRoute()
        default:
            displayBasicRoute()
        }
    }
    
    //MARK: Examples
    
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
    
    private func planRoute() {
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.AMSTERDAM(), andOrig: TTCoordinate.ROTTERDAM())
            .withTravelMode(.car)
            .build()
        routePlanner.plan(with: query)
    }
    
    //MARK: TTRouteResponseDelegate

    func route(_ route: TTRoute, completedWith result: TTRouteResult) {
        guard let plannedRoute = result.routes.first else {
            return
        }
        let mapRoute = TTMapRoute(coordinatesData: plannedRoute, with: routeStyle,
                                  imageStart: iconStart, imageEnd: iconEnd)
        mapView.routeManager.add(mapRoute)
        etaView.show(summary: plannedRoute.summary, style: .plain)
        displayRouteOverview()
        progress.hide()
    }
    
    func route(_ route: TTRoute, completedWith responseError: TTResponseError) {
        handleError(responseError)
    }
    
}
