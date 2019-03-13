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

class RoutingDepartureArrivalTimeViewController: RoutingBaseViewController, TTRouteResponseDelegate {
    
    var actionSheet: ActionSheet!
    var etaStyle = ETAView.ETAViewStyle.plain
    let routePlanner = TTRoute()

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Departure at", "Arrival at"], selectedID: -1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        routePlanner.delegate = self
        actionSheet = ActionSheet(toast: toast, viewController: self)
    }
    
    //MARK: OptionsViewDelegate
    
    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        switch ID {
        case 1:
            displayRouteWithArrival()
        default:
            displayRouteWithDeparture()
        }
    }
    
    //MARK: Examples
    
    func displayRouteWithDeparture() {
        etaStyle = .plain
        actionSheet.show { (date) in
            if let date = date {
                self.progress.show()
                let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.ROTTERDAM(), andOrig: TTCoordinate.AMSTERDAM())
                    .withDepartAt(date)
                    .build()
                self.routePlanner.plan(with: query)
            } else {
                self.optionsView.deselectAll()
            }
        }
    }
    
    func displayRouteWithArrival() {
        etaStyle = .arrival
        actionSheet.show { (date) in
            if let date = date {
                self.progress.show()
                let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.ROTTERDAM(), andOrig: TTCoordinate.AMSTERDAM())
                    .withArriveAt(date)
                    .build()
                self.routePlanner.plan(with: query)
            } else {
                self.optionsView.deselectAll()
            }
        }
    }
    
    //MARK: TTRouteResponseDelegate
    
    func route(_ route: TTRoute, completedWith result: TTRouteResult) {
        guard let plannedRoute = result.routes.first else {
            return
        }
        let mapRoute = TTMapRoute(coordinatesData: plannedRoute,
                                  with: TTMapRouteStyle.defaultActive(),
                                  imageStart: TTMapRoute.defaultImageDeparture(),
                                  imageEnd: TTMapRoute.defaultImageDestination())
        mapView.routeManager.add(mapRoute)
        mapView.routeManager.bring(toFrontRoute: mapRoute)
        etaView.show(summary: plannedRoute.summary, style: etaStyle)
        displayRouteOverview()
        progress.hide()
    }
    
    func route(_ route: TTRoute, completedWith responseError: TTResponseError) {
        handleError(responseError)
    }

}
