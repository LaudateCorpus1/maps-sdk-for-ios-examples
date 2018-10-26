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

import UIKit
import MapsSDKExamplesCommon
import MapsSDKExamplesVC
import TomTomOnlineSDKRouting
import TomTomOnlineSDKMaps

enum BatchRouteType: Int {
    case BatchRouteTypeTravelMode
    case BatchRouteTypeRoute
    case BatchRouteTypeAvoids
}

class RoutingBatchRouteViewController: RoutingBaseViewController, TTBatchRouteVisistor, TTBatchRouteResponseDelegate, TTRouteDelegate {
    
    var batchRoute = TTBatchRoute()
    var type = BatchRouteType.BatchRouteTypeTravelMode
    var routeDesc = [BatchRouteType.BatchRouteTypeTravelMode : ["Travel by Car","Travel by Truck","Travel by Pedestrian"],
                     BatchRouteType.BatchRouteTypeRoute : ["Fastest route", "Shortest route", "Eco route"],
                     BatchRouteType.BatchRouteTypeAvoids : ["Avoid motorways", "Avoid ferries", "Avoid toll roads"]]
    
    
    
    override func setupCenterOnWillHappen() {
        mapView.center(on: TTCoordinate.AMSTERDAM(), withZoom: 10)
    }
    
    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Travel mode", "Route type", "Avoids"], selectedID: -1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.batchRoute = TTBatchRoute()
        self.batchRoute.delegate = self
        self.mapView.routeManager.delegate = self
        
    }
    
    //MARK: OptionsViewDelegate
    
    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        self.mapView.routeManager.removeAllRoutes()
        self.progress.show()
        
        switch ID {
        case 2:
            self.performAvoids()
            self.type = BatchRouteType.BatchRouteTypeAvoids
            break
        case 1:
            self.performRouteType()
            self.type = BatchRouteType.BatchRouteTypeRoute
            break
        default:
            self.performTravelMode()
            self.type = BatchRouteType.BatchRouteTypeTravelMode
            break
        }
    }
    
    //MARK: Examples
    
    func performTravelMode() {
        self.type = .BatchRouteTypeTravelMode
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
        
        self.batchRoute = TTBatchRoute()
        self.batchRoute.delegate = self
        self.batchRoute.batchRoute(with: batchQuery)
    }
    
    func performRouteType() {
        self.type = .BatchRouteTypeRoute
        
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
        
        self.batchRoute = TTBatchRoute()
        self.batchRoute.delegate = self
        self.batchRoute.batchRoute(with: batchQuery)
        
    }
    
    func performAvoids() {
        self.type = .BatchRouteTypeRoute
        
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
        
        self.batchRoute = TTBatchRoute()
        self.batchRoute.delegate = self
        self.batchRoute.batchRoute(with: batchQuery)
    }

    //MARK: TTBatchRouteResponseDelegate
    
    func batch(_ route: TTBatchRoute, completedWith response: TTBatchRouteResponse) {
        self.progress.hide()
        response.visit(self)
    }
    
    func batch(_ route: TTBatchRoute, failedWithError responseError: TTResponseError) {
        self.toast.toast(message: "Error \(String(describing: responseError.userInfo["description"]))")
        self.progress.hide()
        self.optionsView.deselectAll()
    }
    
    //MARK: TTBatchRouteVisistor
    
    func visitRoute(_ response: TTRouteResult) {
        let mapRoute = TTMapRoute(coordinatesData: response.routes.first!,
                                  imageStart: TTMapRoute.defaultImageDeparture(),
                                  imageEnd: TTMapRoute.defaultImageDestination())
        mapRoute.extraData = response.routes.first?.summary
        self.mapView.routeManager.add(mapRoute)
        self.progress.hide()
        self.displayRouteOverview()
    }
    
    //MARK: TTRouteDelegate
    func routeClicked(_ route: TTMapRoute) {
        for mapRoute in self.mapView.routeManager.routes {
            mapRoute.isActive = route == mapRoute
        }
        let desc = routeDesc[type]![mapView.routeManager.routes.index(of: route)!]
        updateEta(mapRoute: route, desc: desc)
    }
    
    //MARK: display ETA
    func updateEta(mapRoute: TTMapRoute, desc: String) {
        let summary = mapRoute.extraData as! TTSummary
        let eta = summary.arrivalTime
        
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.hour,.minute])
        let components:NSDateComponents =  calendar.dateComponents(unitFlags, from: eta!) as NSDateComponents
        let dateInString = "\(components.hour):\(components.minute) \(desc)"
        self.etaView.update(eta: dateInString, metersDistance: summary.lengthInMeters.uintValue)
    }
}
