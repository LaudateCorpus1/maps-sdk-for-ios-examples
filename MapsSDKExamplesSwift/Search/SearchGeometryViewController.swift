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

import CoreLocation
import MapsSDKExamplesCommon
import MapsSDKExamplesVC
import TomTomOnlineSDKMaps
import TomTomOnlineSDKSearch
import UIKit

class SearchGeometryViewController: MapBaseViewController, TTGeometrySearchDelegate {
    let geometrySearch = TTGeometrySearch()
    var geometryShape: [TTSearchShape] = []

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Parking", "ATM", "Grocery"], selectedID: -1)
    }

    override func setupCenterOnWillHappen() {
        mapView.center(on: TTCoordinate.AMSTERDAM_A10(), withZoom: 10)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createShapesForSearch()
        geometrySearch.delegate = self
    }

    private func createShapesForSearch() {
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
        geometryShape.append(TTSearchPolygon(coordinates: &coordinates, count: UInt(coordinates.count)))

        let mapCircle = TTCircle(center: TTCoordinate.AMSTERDAM_CIRCLE(), radius: 2000, width: 2, color: TTColor.RedSemiTransparent(), fill: true, colorOutlet: TTColor.RedSemiTransparent())
        mapView.annotationManager.add(mapCircle)
        geometryShape.append(TTSearchCircle(center: TTCoordinate.AMSTERDAM_CIRCLE(), radius: 2000))
    }

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        progress.show()
        mapView.annotationManager.removeAllAnnotations()
        switch ID {
        case 2:
            searchForGrocery()
        case 1:
            searchForATM()
        default:
            searchForParking()
        }
    }

    // MARK: Examples

    func searchForParking() {
        let query = TTGeometrySearchQueryBuilder.create(withTerm: "Parking", searchShapes: geometryShape)
            .withLimit(30)
            .build()
        geometrySearch.search(with: query)
    }

    func searchForATM() {
        let query = TTGeometrySearchQueryBuilder.create(withTerm: "ATM", searchShapes: geometryShape)
            .withLimit(30)
            .build()
        geometrySearch.search(with: query)
    }

    func searchForGrocery() {
        let query = TTGeometrySearchQueryBuilder.create(withTerm: "Grocery", searchShapes: geometryShape)
            .withLimit(30)
            .build()
        geometrySearch.search(with: query)
    }

    // MARK: TTGeometrySearchDelegate

    func search(_: TTGeometrySearch, completedWith response: TTGeometrySearchResponse) {
        progress.hide()
        for result in response.results {
            let annotation = TTAnnotation(coordinate: result.position)
            mapView.annotationManager.add(annotation)
        }
    }

    func search(_: TTGeometrySearch, failedWithError error: TTResponseError) {
        handleError(error)
    }
}
