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
import TomTomOnlineSDKSearch
import UIKit

class SearchBatchViewController: MapBaseViewController, TTBatchSearchDelegate, TTBatchVisistor {
    let batchSearch = TTBatchSearch(key: Key.Search)

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Parking", "Gas", "Bar"], selectedID: -1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        batchSearch.delegate = self
    }

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        mapView.annotationManager.clustering = true
        mapView.annotationManager.removeAllOverlays()
        mapView.annotationManager.removeAllAnnotations()
        progress.show()
        switch ID {
        case 2:
            batchSearch(term: "Bar")
        case 1:
            batchSearch(term: "Gas")
        default:
            batchSearch(term: "Parking")
        }
    }

    // MARK: Examples

    func batchSearch(term: String) {
        let query1 = TTSearchQueryBuilder.create(withTerm: term)
            .withCategory(true)
            .withPosition(TTCoordinate.AMSTERDAM_CENTER_LOCATION())
            .withLimit(10)
            .build()
        let query2 = TTSearchQueryBuilder.create(withTerm: term)
            .withCategory(true)
            .withPosition(TTCoordinate.HAARLEM())
            .withLimit(15)
            .build()
        let geometry = TTSearchCircle(center: TTCoordinate.HOOFDDORP(), radius: 4000)
        let geometryQuery = TTGeometrySearchQueryBuilder.create(withTerm: term, searchShapes: [geometry])
            .build()
        let batchQuery = TTBatchQueryBuilder.createSearchQuery(query1)
            .add(query2)
            .addGeometryQuery(geometryQuery)
            .build()
        batchSearch.batchSearch(with: batchQuery)
    }

    // MARK: TTBatchSearchDelegate

    func batch(_: TTBatchSearch, completedWith response: TTBatchResponse) {
        progress.hide()
        response.visit(self)
    }

    func batch(_: TTBatchSearch, failedWithError error: TTResponseError) {
        handleError(error)
    }

    // MARK: TTBatchVisistor

    func visitSearch(_ response: TTSearchResponse) {
        for result in response.results {
            let annotation = TTAnnotation(coordinate: result.position)
            mapView.annotationManager.add(annotation)
        }
    }

    func visitGeometrySearch(_ response: TTGeometrySearchResponse) {
        for result in response.results {
            let annotation = TTAnnotation(coordinate: result.position)
            mapView.annotationManager.add(annotation)
        }

        let circle = TTCircle(center: TTCoordinate.HOOFDDORP(), radius: 4000, width: 2, color: TTColor.RedSemiTransparent(), fill: true, colorOutlet: TTColor.RedSemiTransparent())
        mapView.annotationManager.add(circle)

        mapView.zoomToAllAnnotations()
    }
}
