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

class RoutingBatchReachableRouteViewController: RoutingBaseViewController, TTBatchRouteVisistor, TTBatchRouteResponseDelegate, TTAnnotationDelegate {
    
    let batchRoute = TTBatchRoute()
    let queryFactory = ReachableRangeQueryFactory()
    var polylines: [TTPolyline] = []
    var index = 0

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: [], selectedID: -1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.annotationManager.delegate = self
        batchRoute.delegate = self
        requestForBatch()
        etaView.update(text: "Touch polyline to see the description...", icon: UIImage(named: "info_small")!)
    }
    
    private func requestForBatch() {
        let batchQuery = TTBatchRouteQueryBuilder.createReachableRangeQuery(queryFactory.createReachableRangeQueryForElectric())
            .add(queryFactory.createReachableRangeQueryForCombustion())
            .add(queryFactory.createReachableRangeQueryForElectricLimitTo2Hours())
            .build()
        batchRoute.batchRoute(with: batchQuery)
        progress.show()
    }
    
    //MARK: TTBatchRouteResponseDelegate
    
    func batch(_ route: TTBatchRoute, completedWith response: TTBatchRouteResponse) {
        progress.hide()
        response.visit(self)
        mapView.zoom(toCoordinatesDataCollection: polylines)
    }

    func batch(_ route: TTBatchRoute, failedWithError responseError: TTResponseError) {
        handleError(responseError)
    }

    //MARK: TTBatchRouteVisistor

    func visitReachableRange(_ response: TTReachableRangeResponse) {
        var coordinates: [CLLocationCoordinate2D] = []
        for i in 0..<response.result.boundriesCount {
            coordinates.append(response.result.boundry(at: i))
        }
        coordinates.append(response.result.boundry(at: 0))
        
        let polyline = TTPolyline(coordinates: &coordinates, count: UInt(coordinates.count), opacity: 1, width: 3, color: determinePolylineColor(index))
        polyline.tag = determinePolylineDescription(index) as NSObject
        mapView.annotationManager.add(polyline)
        index+=1
        polylines.append(polyline)
    }
    
    //MARK: TTAnnotationDelegate
    
    func annotationManager(_ manager: TTAnnotationManager, touchUp polyline: TTPolyline) {
        guard let description = polyline.tag as? String else {
            return
        }
        etaView.update(text: description, icon: UIImage(named: "info_small")!)
    }
    
    private func determinePolylineColor(_ index: Int) -> UIColor {
        switch (index) {
        case 2:
            return TTColor.Black()
        case 1:
            return TTColor.Blue()
        default:
            return TTColor.GreenLight()
        }
    }
    
    private func determinePolylineDescription(_ index: Int) -> String {
        switch (index) {
        case 2:
            return "Electric with power for 2 h"
        case 1:
            return "Combustion"
        default:
            return "Electric"
        }
    }

}
