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

import MapsSDKExamplesCommon
import MapsSDKExamplesVC
import TomTomOnlineSDKRouting
import TomTomOnlineSDKMaps

class RoutingAvoidVignettesAndAreasViewController: RoutingBaseViewController, TTRouteResponseDelegate, TTRouteDelegate, TTAnnotationDelegate {
    
    let routePlannerBasic = TTRoute()
    let routePlannerAvoid = TTRoute()
    var dispatchGroup = DispatchGroup()
    
    
    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["No avoids", "Avoid Vignettes","Avoid area"], selectedID: -1)
    }
    
    override func setupCenterOnWillHappen() {
        mapView.center(on: TTCoordinate.BUDAPEST_LOCATION(), withZoom: 4)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.annotationManager.delegate = self
        mapView.routeManager.delegate = self
    }
    
    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        mapView.routeManager.removeAllRoutes()
        progress.show()
        switch ID {
        case 2:
            startRoutingAvoidArea()
        case 1:
            startRoutingAvoidsVignettes()
        default:
            startRoutingNoAvoids()
        }
    }
    
    //MARK: No avoids
    func startRoutingNoAvoids() {
        mapView.annotationManager.removeAllOverlays()
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.ROMANIA(), andOrig: TTCoordinate.CZECH_REPUBLIC())
            .withTraffic(true)
            .build()
        
        routePlannerBasic.plan(with: query) { (result, error) in
            if error != nil {
                self.handleError(error)
                self.routePlannerAvoid.cancel()
            }else {
                guard let result = result else { return }
                guard let plannedRoute = result.routes.first else { return }
                self.displayRoute(etaValue: "No avoids", plannedRoute: plannedRoute, routeStyle: TTMapRouteStyle.defaultActive())
                self.progress.hide()
                
            }
        }
    }
    
    //MARK: Avoid Vignettes
    func startRoutingAvoidsVignettes() {
        dispatchGroup = DispatchGroup()
        mapView.annotationManager.removeAllOverlays()
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.ROMANIA(), andOrig: TTCoordinate.CZECH_REPUBLIC())
            .withTraffic(true)
            .build()
        
        dispatchGroup.enter()
        routePlannerBasic.plan(with: query) { (result, error) in
            if error != nil {
                self.handleError(error)
                self.routePlannerAvoid.cancel()
            }else {
                guard let result = result else { return }
                guard let plannedRoute = result.routes.first else { return }
                self.displayRoute(etaValue: "Avoids Vignettes", plannedRoute: plannedRoute, routeStyle: TTMapRouteStyle.defaultActive())
            }
            self.dispatchGroup.leave()
        }
        
        let vignettesArray = ["HUN","CZE","SVK"]
        dispatchGroup.enter()
        let query2 = TTRouteQueryBuilder.create(withDest: TTCoordinate.ROMANIA(), andOrig: TTCoordinate.CZECH_REPUBLIC())
            .withTraffic(false)
            .withAvoidVignettesArray(vignettesArray)
            .build()
        routePlannerAvoid.plan(with: query2) { (result, error) in
            if error != nil {
                self.handleError(error)
                self.routePlannerBasic.cancel()
            }else {
                guard let result = result else { return }
                guard let plannedRoute = result.routes.first else { return }
                self.displayRoute(etaValue: "Avoids Vignettes", plannedRoute: plannedRoute, routeStyle: self.setRouteStyle(fillColor: TTColor.Pink(), outlineColor: TTColor.Purple()))
            }
            self.dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            self.progress.hide()
        }
    }
    
    
    //MARK: Avoid Area
    func startRoutingAvoidArea() {
        mapView.annotationManager.removeAllOverlays()
        dispatchGroup = DispatchGroup()
        let pointsCount = 5
        var coordinateArray = [TTCoordinate.ARAD_TOP_LEFT_NEIGHBORHOOD(),
                               TTCoordinate.ARAD_TOP_RIGHT_NEIGHBORHOOD(),
                               TTCoordinate.ARAD_BOTTOM_RIGHT_NEIGHBORHOOD(),
                               TTCoordinate.ARAD_BOTTOM_LEFT_NEIGHBORHOOD(),
                               TTCoordinate.ARAD_TOP_LEFT_NEIGHBORHOOD()]
        let polyline = TTPolyline(coordinates: &coordinateArray, count: UInt(pointsCount), opacity: 1, width: 4, color: TTColor.Blue())
        mapView.annotationManager.add(polyline)
        
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.ROMANIA(), andOrig: TTCoordinate.CZECH_REPUBLIC())
            .withTraffic(true)
            .build()
        dispatchGroup.enter()
        routePlannerBasic.plan(with: query) { (result, error) in
            if error != nil {
                self.handleError(error)
                self.routePlannerAvoid.cancel()
            }else {
                guard let result = result else { return }
                guard let plannedRoute = result.routes.first else { return }
                self.displayRoute(etaValue: "Avoid area", plannedRoute: plannedRoute, routeStyle: self.setRouteStyle(fillColor: TTColor.BlueLight(), outlineColor: TTColor.BlueLight()))
            }
            self.dispatchGroup.leave()
        }
        
        
        let boundingBox = TTLatLngBounds(seBounds: TTCoordinate.ARAD_TOP_LEFT_NEIGHBORHOOD(), nwBounds: TTCoordinate.ARAD_BOTTOM_RIGHT_NEIGHBORHOOD())
        var boundingBoxArray = [boundingBox]
        let query2 = TTRouteQueryBuilder.create(withDest: TTCoordinate.ROMANIA(), andOrig: TTCoordinate.CZECH_REPUBLIC())
            .withAvoidArea(&boundingBoxArray, count: UInt(boundingBoxArray.count))
            .withTraffic(true)
            .build()
        dispatchGroup.enter()
        routePlannerAvoid.plan(with: query2) { (result, error) in
            if error != nil {
                self.handleError(error)
                self.routePlannerBasic.cancel()
            }else {
                guard let result = result else { return }
                guard let plannedRoute = result.routes.first else { return }
                self.displayRoute(etaValue: "Avoid area", plannedRoute: plannedRoute, routeStyle: self.setRouteStyle(fillColor: TTColor.GreenBright(), outlineColor: TTColor.GreenBright()))
            }
            self.dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            self.progress.hide()
        }
    }

    //MARK: Drow route
    func displayRoute(etaValue: String, plannedRoute: TTFullRoute, routeStyle: TTMapRouteStyle){
        
        let mapRoute = TTMapRoute(coordinatesData: plannedRoute,
                                  with: routeStyle,
                                  imageStart: TTMapRoute.defaultImageDeparture(),
                                  imageEnd: TTMapRoute.defaultImageDestination())
        mapView.routeManager.add(mapRoute)
        mapView.routeManager.bring(toFrontRoute: mapRoute)
        etaView.update(eta: etaValue, metersDistance: UInt(plannedRoute.summary.lengthInMetersValue))
        displayRouteOverview()
    }
    
    //MARK: Route Style
    func setRouteStyle(fillColor: UIColor, outlineColor: UIColor) -> TTMapRouteStyle{
        let routeStyle = TTMapRouteStyleBuilder()
            .withWidth(1.0)
            .withFill(fillColor)
            .withOutlineColor(outlineColor)
            .build()
        
        return routeStyle
    }
}
