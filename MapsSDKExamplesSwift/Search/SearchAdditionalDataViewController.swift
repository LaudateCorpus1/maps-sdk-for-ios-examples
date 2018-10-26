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
import TomTomOnlineSDKSearch
import TomTomOnlineSDKMaps

class SearchAdditionalDataViewController: MapBaseViewController, TTSearchDelegate, TTAdditionalDataSearchDelegate {
    
    let search = TTSearch()
    let searchAdditionalData = TTAdditionalDataSearch()
    
    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Amsterdam", "Berlin", "Poland"], selectedID: -1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        search.delegate = self
        searchAdditionalData.delegate = self
    }
    
    //MARK: OptionsViewDelegate
    
    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        progress.show()
        mapView.annotationManager.removeAllOverlays()
        switch ID {
        case 2:
            displayAdditionalDataPoland()
        case 1:
            displayAdditionalDataBerlin()
        default:
            displayAdditionalDataAmsterdam()
        }
    }
    
    //MARK: Examples
    
    func displayAdditionalDataAmsterdam() {
        let query = TTSearchQueryBuilder.create(withTerm: "Amsterdam")
            .withIdxSet(.geographies)
            .build()
        search.search(with: query)
    }
    
    func displayAdditionalDataBerlin() {
        let query = TTSearchQueryBuilder.create(withTerm: "Berlin")
            .withIdxSet(.geographies)
            .build()
        search.search(with: query)
    }
    
    func displayAdditionalDataPoland() {
        let query = TTSearchQueryBuilder.create(withTerm: "Poland")
            .withIdxSet(.geographies)
            .build()
        search.search(with: query)
    }
    
    //MARK: TTSearchDelegate
    
    func search(_ search: TTSearch, completedWith response: TTSearchResponse) {
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
    
    func search(_ search: TTSearch, failedWithError error: TTResponseError) {
        toast.toast(message: "error " + (error.userInfo["description"] as! String))
        progress.hide()
        optionsView.deselectAll()
    }
    
    //MARK: TTAdditionalDataSearchDelegate
    
    func additionalDataSearch(_ additionalDataSearch: TTAdditionalDataSearch, completedWith response: TTAdditionalDataSearchResponse) {
        progress.hide()
        guard let result = response.results.first else {
            return
        }
        let visitor = PolygonAdditionalDataVisitior()
        result.visit(visitor)
        var mapPolygons: [TTPolygon] = []
        for lineString in visitor.lineStrings {
            let mapPolygon = TTPolygon(coordinatesData: lineString, opacity: 0.7, color: TTColor.Red(), colorOutline: TTColor.Red())
            mapPolygons.append(mapPolygon)
            mapView.annotationManager.add(mapPolygon)
        }
        mapView.zoom(toCoordinatesDataCollection: mapPolygons)
    }
    
    func additionalDataSearch(_ additionalDataSearch: TTAdditionalDataSearch, failedWithError error: TTResponseError) {
        toast.toast(message: "error " + (error.userInfo["description"] as! String))
        progress.hide()
        optionsView.deselectAll()
    }

}

class PolygonAdditionalDataVisitior: NSObject, TTADPGeoJsonObjectVisitor, TTADPGeoJsonGeoVisitor {
    
    var lineStrings: [TTADPLineString] = []
    
    func visit(_ featureCollection: TTADPFeatureCollection) {
        for feature in featureCollection.features {
            feature.visitResult(self)
        }
    }
    
    func visit(_ polygon: TTADPPolygon) {
        lineStrings.append(polygon.exteriorRing)
    }
    
    func visit(_ multiPolygon: TTADPMultiPolygon) {
        for polygon in multiPolygon.polygons {
            lineStrings.append(polygon.exteriorRing)
        }
    }
    
}
