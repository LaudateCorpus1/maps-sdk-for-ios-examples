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

class LongDistanceEVRoutingViewController: RoutingBaseViewController, TTRouteResponseDelegate {
    let evPlanner = LongDistanceEVService(key: Key.Routing)

    override func onMapReady() {
        super.onMapReady()
        planRouteShortRange()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.annotationManager.delegate = self
    }

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Short range vehicle", "Long range vehicle"], selectedID: 0)
    }

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        switch ID {
        case 1:
            planRouteLongRange()
        case 0:
            planRouteShortRange()
        default:
            planRouteShortRange()
        }
    }

    func planRouteLongRange() {
        clearMap()
        progress.show()
        let origin = TTCoordinate.AMSTERDAM()
        let destination = TTCoordinate.BERLIN()
        let vehicle = ElectricVehicle.longRange
        let route = RouteOptions.fastestWithTraffic
        let chargeSchema = LongRangeChargingSchema()

        evPlanner.planRoute(origin: origin, destination: destination, electricVehicle: vehicle, route: route, charging: chargeSchema) { [weak self] routes, _ in
            guard let self = self else { return }
            if let route = routes?.first {
                self.drawRoute(route, vehicle: vehicle)
                self.drawChargingStation(route)
            }
        }
    }

    func planRouteShortRange() {
        clearMap()
        progress.show()
        let origin = TTCoordinate.AMSTERDAM()
        let destination = TTCoordinate.BERLIN()
        let vehicle = ElectricVehicle.shortRange
        let route = RouteOptions.fastestWithTraffic
        let chargeSchema = ShortRangeChargingSchema()
        evPlanner.planRoute(origin: origin, destination: destination, electricVehicle: vehicle, route: route, charging: chargeSchema) { [weak self] routes, _ in
            guard let self = self else { return }
            if let route = routes?.first {
                self.drawRoute(route, vehicle: vehicle)
                self.drawChargingStation(route)
            }
        }
    }

    func chargeStationAnnotations(route: FullRouteEV) -> [ChargeStationAnnotation] {
        return route.legs?.map { (leg) -> ChargeStationAnnotation? in
            guard let info = leg.legSummary?.chargingInformationAtEndOfLeg, info.chargingTime > 0 else {
                return nil
            }
            guard let coordinate = leg.points?.last?.coordinate else {
                return nil
            }
            return ChargeStationAnnotation(info: info, coordinate: coordinate)
        }.compactMap { $0 } ?? []
    }

    func drawChargingStation(_ route: FullRouteEV) {
        let annotations = self.chargeStationAnnotations(route: route)
        mapView.annotationManager.add(annotations)
    }

    func drawRoute(_ route: FullRouteEV, vehicle: ElectricVehicle) {
        let mapRoute = TTMapRoute(coordinatesData: route,
                                  with: TTMapRouteStyle.defaultActive(),
                                  imageStart: TTMapRoute.defaultImageDeparture(),
                                  imageEnd: TTMapRoute.defaultImageDestination())
        mapView.routeManager.add(mapRoute)
        mapView.routeManager.bring(toFrontRoute: mapRoute)
        displayRouteOverview()
        progress.hide()

        guard let summary = route.summary else {
            return
        }

        etaView.show(summary: summary, vehicle: vehicle)
    }

    func clearMap() {
        mapView.routeManager.removeAllRoutes()
        mapView.annotationManager.removeAllAnnotations()
    }
}

extension LongDistanceEVRoutingViewController: TTAnnotationDelegate {
    func annotationManager(_: TTAnnotationManager, annotationSelected annotation: TTAnnotation) {
        mapView.center(on: annotation.coordinate)
    }

    func annotationManager(_: TTAnnotationManager, viewForSelectedAnnotation selectedAnnotation: TTAnnotation) -> UIView & TTCalloutView {
        guard let selectedAnnotation = selectedAnnotation as? ChargeStationAnnotation else {
            return TTCalloutOutlineView(text: "-")
        }
        let view = ChargingStationCalloutView(text: "Wait time: \(Int(selectedAnnotation.info.chargingTime / 60)) minutes", title: "Charging station waypoint")
        return TTCalloutOutlineView(uiView: view)
    }
}
