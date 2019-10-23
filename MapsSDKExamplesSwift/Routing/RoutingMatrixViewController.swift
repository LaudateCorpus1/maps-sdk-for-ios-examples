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

class RoutingMatrixViewController: RoutingBaseViewController, TTMatrixRouteResponseDelegate {
    let matrixRouting = TTMatrixRoute()
    var oneToManySelected = true

    override func setupInitialCameraPosition() {
        mapView.center(on: TTCoordinate.AMSTERDAM_CENTER_LOCATION(), withZoom: 12)
    }

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["One to Many", "Many to Many"], selectedID: -1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        matrixRouting.delegate = self
    }

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        hideMatrixEta()
        mapView.annotationManager.removeAllAnnotations()
        mapView.annotationManager.removeAllOverlays()
        progress.show()
        switch ID {
        case 1:
            oneToManySelected = false
            displayManyToMany()
        default:
            oneToManySelected = true
            displayOneToMany()
        }
    }

    // MARK: Examples

    func displayOneToMany() {
        let query = TTMatrixRouteQueryBuilder.create(withOrigin: TTCoordinate.AMSTERDAM_CENTER_LOCATION(),
                                                     withDestination: TTCoordinate.AMSTERDAM_RESTAURANT_BRIDGES())
            .addDestination(TTCoordinate.AMSTERDAM_RESTAURANT_GREETJE())
            .addDestination(TTCoordinate.AMSTERDAM_RESTAURANT_LA_RIVE())
            .addDestination(TTCoordinate.AMSTERDAM_RESTAURANT_WAGAMAMA())
            .addDestination(TTCoordinate.AMSTERDAM_RESTAURANT_ENVY())
            .build()
        matrixRouting.matrixRoute(with: query)
    }

    func displayManyToMany() {
        let query = TTMatrixRouteQueryBuilder.create(withOrigin: TTCoordinate.PASSENGER_ONE(),
                                                     withDestination: TTCoordinate.TAXI_ONE())
            .addOrigin(TTCoordinate.PASSENGER_TWO())
            .addDestination(TTCoordinate.TAXI_TWO())
            .build()
        matrixRouting.matrixRoute(with: query)
    }

    // MARK: TTMatrixRouteResponseDelegate

    func matrix(_: TTMatrixRoute, completedWith response: TTMatrixRouteResponse) {
        if oneToManySelected {
            presentOneToMany(response: response)
        } else {
            presentManyToMany(response: response)
        }
    }


    func matrix(_: TTMatrixRoute, completedWith responseError: TTResponseError) {
        handleError(responseError)
    }


    func presentOneToMany(response: TTMatrixRouteResponse) {
        let annotationOrigin = TTAnnotation(coordinate: TTCoordinate.AMSTERDAM_CENTER_LOCATION(), annotationImage: TTAnnotationImage.createPNG(withName: "Car")!, anchor: .bottom, type: .focal)
        mapView.annotationManager.add(annotationOrigin)
        for result in response.results {
            let annotation = TTAnnotation(coordinate: result.key.destination)
            mapView.annotationManager.add(annotation)

            var coordinates = [result.key.origin, result.key.destination]
            let polyline = TTPolyline(coordinates: &coordinates, count: UInt(coordinates.count), opacity: 1, width: 4, color: determineColor(matrixRoutingResultKey: result.key, response: response))
            mapView.annotationManager.add(polyline)
        }
        progress.hide()
        showMatrixEta(oneToManySelected, withMatrixResponse: response)
        zoomToAllMarkers()
    }

    func presentManyToMany(response: TTMatrixRouteResponse) {
        for result in response.results {
            let annotationOrigin = TTAnnotation(coordinate: result.key.origin, annotationImage: TTAnnotationImage.createPNG(withName: "Walk")!, anchor: .bottom, type: .focal)
            mapView.annotationManager.add(annotationOrigin)
            let annotationDestination = TTAnnotation(coordinate: result.key.destination, annotationImage: TTAnnotationImage.createPNG(withName: "Car")!, anchor: .bottom, type: .focal)
            mapView.annotationManager.add(annotationDestination)

            var coordinates = [result.key.origin, result.key.destination]
            let polyline = TTPolyline(coordinates: &coordinates, count: UInt(coordinates.count), opacity: 1, width: 4, color: determineColor(matrixRoutingResultKey: result.key, response: response))
            mapView.annotationManager.add(polyline)
        }
        progress.hide()
        showMatrixEta(oneToManySelected, withMatrixResponse: response)
        zoomToAllMarkers()
    }

    private func determineColor(matrixRoutingResultKey: TTMatrixRoutingResultKey, response: TTMatrixRouteResponse) -> UIColor {
        guard let result = response.results[matrixRoutingResultKey], let matrixSummary = result.summary else {
            return TTColor.GreenDark()
        }
        let currentEta = matrixSummary.arrivalTime
        var minEta = currentEta
        for result in response.results.values {
            if CLLocation.locationsEquals(first: result.origin, second: matrixRoutingResultKey.origin) {
                if let summary = result.summary {
                    if summary.arrivalTime < minEta {
                        minEta = summary.arrivalTime
                    }
                }
            }
        }
        return currentEta == minEta ? TTColor.GreenDark() : TTColor.Gray()
    }
}
