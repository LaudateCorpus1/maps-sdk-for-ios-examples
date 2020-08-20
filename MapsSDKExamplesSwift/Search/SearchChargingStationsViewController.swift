//
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

import CoreLocation
import MapKit
import MapsSDKExamplesCommon
import MapsSDKExamplesVC
import TomTomOnlineSDKMaps
import TomTomOnlineSDKRouting
import TomTomOnlineSDKSearch
import UIKit

class SearchChargingStationsViewController: MapBaseViewController {
    let service = EVChargingStationService(apiKey: Key.Search)
    let routePlanner = TTRoute(key: Key.Routing)

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Along the route", "Fuzzy", "Geometry"], selectedID: -1)
    }

    override func setupInitialCameraPosition() {
        mapView.center(on: TTCoordinate.AMSTERDAM_A10(), withZoom: 10)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.annotationManager.delegate = self
    }

    private func drawShapes(coordinates: [CLLocationCoordinate2D]) {
        mapView.annotationManager.removeAllAnnotations()
        var coordinates = [CLLocationCoordinate2DMake(52.37874, 4.90482),
                           CLLocationCoordinate2DMake(52.37664, 4.92559),
                           CLLocationCoordinate2DMake(52.37497, 4.94877),
                           CLLocationCoordinate2DMake(52.36805, 4.97246),
                           CLLocationCoordinate2DMake(52.34918, 4.95993),
                           CLLocationCoordinate2DMake(52.34016, 4.95169),
                           CLLocationCoordinate2DMake(52.32894, 4.91392),
                           CLLocationCoordinate2DMake(52.34048, 4.88611),
                           CLLocationCoordinate2DMake(52.33953, 4.84388),
                           CLLocationCoordinate2DMake(52.37067, 4.8432),
                           CLLocationCoordinate2DMake(52.38492, 4.84663),
                           CLLocationCoordinate2DMake(52.40011, 4.85058),
                           CLLocationCoordinate2DMake(52.38995, 4.89075)]
        let mapPolygon = TTPolygon(coordinates: &coordinates, count: UInt(coordinates.count), opacity: 1, color: TTColor.RedSemiTransparent(), colorOutline: TTColor.RedSemiTransparent())
        mapView.annotationManager.add(mapPolygon)
    }

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        progress.show()
        mapView.annotationManager.removeAllAnnotations()
        mapView.annotationManager.removeAllOverlays()
        mapView.routeManager.removeAllRoutes()

        switch ID {
        case 2:
            searchGeometry()
        case 1:
            searchFuzzy()
        default:
            searchAlongTheRoute()
        }
    }

    // MARK: Examples

    func searchFuzzy() {
        service.search(topLeft: TTCoordinate.AMSTERDAM_TOP_LEFT(), bottomRight: TTCoordinate.AMSTERDAM_BOTTOM_RIGHT()) { result, _ in
            guard let result = result else {
                return
            }
            self.search(completedWith: result)
        }
    }

    func searchAlongTheRoute() {
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.HAARLEM(), andOrig: TTCoordinate.AMSTERDAM())
            .build()

        routePlanner.plan(with: query) { [weak self] result, _ in
            guard let route = result?.routes.first else {
                return
            }

            let mapRoute = TTMapRoute(coordinatesData: route,
                                      with: TTMapRouteStyle.defaultActive(),
                                      imageStart: TTMapRoute.defaultImageDeparture(),
                                      imageEnd: TTMapRoute.defaultImageDestination())
            self?.mapView.routeManager.add(mapRoute)

            let routeLocations = route.coordinatesData().map { CLLocation($0.mkCoordinateValue) }
            self?.service.search(route: routeLocations, completion: { chargingStationResult, _ in
                guard let chargingStationResult = chargingStationResult else {
                    return
                }
                self?.search(completedWith: chargingStationResult)
            })
        }
    }

    func searchGeometry() {
        let coordinates = [CLLocationCoordinate2DMake(52.37874, 4.90482),
                           CLLocationCoordinate2DMake(52.37664, 4.92559),
                           CLLocationCoordinate2DMake(52.37497, 4.94877),
                           CLLocationCoordinate2DMake(52.36805, 4.97246),
                           CLLocationCoordinate2DMake(52.34918, 4.95993),
                           CLLocationCoordinate2DMake(52.34016, 4.95169),
                           CLLocationCoordinate2DMake(52.32894, 4.91392),
                           CLLocationCoordinate2DMake(52.34048, 4.88611),
                           CLLocationCoordinate2DMake(52.33953, 4.84388),
                           CLLocationCoordinate2DMake(52.37067, 4.8432),
                           CLLocationCoordinate2DMake(52.38492, 4.84663),
                           CLLocationCoordinate2DMake(52.40011, 4.85058),
                           CLLocationCoordinate2DMake(52.38995, 4.89075)]

        drawShapes(coordinates: coordinates)

        let locations = coordinates.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
        let polygonShape = PolygonShape(locations: locations)
        service.search(shape: [polygonShape]) { result, _ in
            guard let result = result else {
                return
            }
            self.search(completedWith: result)
        }
    }

    func search(completedWith stations: [ChargingStationDetails]) {
        progress.hide()
        for result in stations {
            let annotation = ChargeStationDetailsAnnotation(info: result)
            mapView.annotationManager.add(annotation)
        }
    }
}

extension SearchChargingStationsViewController: TTAnnotationDelegate {
    func annotationManager(_: TTAnnotationManager, annotationSelected annotation: TTAnnotation) {
        mapView.center(on: annotation.coordinate)
    }

    func annotationManager(_: TTAnnotationManager, viewForSelectedAnnotation selectedAnnotation: TTAnnotation) -> UIView & TTCalloutView {
        guard let selectedAnnotation = selectedAnnotation as? ChargeStationDetailsAnnotation else {
            return TTCalloutOutlineView(text: "-")
        }
        let address = selectedAnnotation.freeFormAddress()
        let availabilityText = selectedAnnotation.readableAvailability()
        let text = "\(address)\n\(availabilityText)"
        let view = ChargingStationCalloutView(text: text, title: selectedAnnotation.info.name, height: 100)
        view.iconView.image = UIImage(named: "ic_ev_slow_charging")
        return TTCalloutOutlineView(uiView: view)
    }
}
