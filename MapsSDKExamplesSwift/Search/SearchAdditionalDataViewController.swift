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

class SearchAdditionalDataViewController: MapBaseViewController, TTSearchDelegate, TTAdditionalDataSearchDelegate {
    let search = TTSearch()
    let searchAdditionalData = TTAdditionalDataSearch()

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Poland", "Amsterdam", "Schiphol"], selectedID: -1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        search.delegate = self
        searchAdditionalData.delegate = self
    }

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        progress.show()
        mapView.annotationManager.removeAllOverlays()
        switch ID {
        case 2:
            displayAdditionalDataLanduse()
        case 1:
            displayAdditionalDataAmsterdam()
        default:
            displayAdditionalDataPoland()
        }
    }

    // MARK: Examples

    func displayAdditionalDataAmsterdam() {
        let query = TTSearchQueryBuilder.create(withTerm: "Amsterdam")
            .withIdxSet(.geographies)
            .build()
        search.search(with: query)
    }

    func displayAdditionalDataLanduse() {
        let query = TTSearchQueryBuilder.create(withTerm: "Amsterdam Airport Schiphol")
            .withIdxSet(.pointOfInterest)
            .build()
        search.search(with: query)
    }

    func displayAdditionalDataPoland() {
        let query = TTSearchQueryBuilder.create(withTerm: "Poland")
            .withIdxSet(.geographies)
            .build()
        search.search(with: query)
    }

    // MARK: TTSearchDelegate

    func search(_: TTSearch, completedWith response: TTSearchResponse) {
        guard let result = response.results.first else {
            return
        }
        guard let additionalData = result.additionalDataSources else {
            return
        }
        guard let geometryData = additionalData.geometryDataSource else {
            return
        }
        let query = TTAdditionalDataSearchQueryBuilder.create(with: geometryData).build()
        searchAdditionalData.additionalDataSearch(with: query)
    }


    func search(_: TTSearch, failedWithError error: TTResponseError) {
        handleError(error)
    }

    // MARK: TTAdditionalDataSearchDelegate

    func additionalDataSearch(_: TTAdditionalDataSearch, completedWith response: TTAdditionalDataSearchResponse) {
        progress.hide()
        guard let result = response.results.first else {
            return
        }
        let visitor = PolygonAdditionalDataVisitior()
        result.visitGeoJSONResult(visitor)
        var mapPolygons: [TTPolygon] = []
        for lineString in visitor.lineStrings {
            let mapPolygon = TTPolygon(coordinatesData: lineString, opacity: 0.7, color: TTColor.Red(), colorOutline: TTColor.Red())
            mapPolygons.append(mapPolygon)
            mapView.annotationManager.add(mapPolygon)
        }
        mapView.zoom(toCoordinatesDataCollection: mapPolygons)
    }


    func additionalDataSearch(_: TTAdditionalDataSearch, failedWithError error: TTResponseError) {
        handleError(error)
    }
}

class PolygonAdditionalDataVisitior: NSObject, TTGeoJSONObjectVisitor, TTGeoJSONGeoVisitor {
    var lineStrings: [TTGeoJSONLineString] = []

    func visit(_ featureCollection: TTGeoJSONFeatureCollection) {
        for feature in featureCollection.features {
            feature.visitResult(self)
        }
    }

    func visit(_ polygon: TTGeoJSONPolygon) {
        lineStrings.append(polygon.exteriorRing)
    }

    func visit(_ multiPolygon: TTGeoJSONMultiPolygon) {
        for polygon in multiPolygon.polygons {
            lineStrings.append(polygon.exteriorRing)
        }
    }
}
