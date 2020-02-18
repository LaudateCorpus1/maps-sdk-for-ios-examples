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

class SearchPolygonsForRevGeoViewController: MapBaseViewController, TTMapViewDelegate, TTAnnotationDelegate, TTReverseGeocoderDelegate, TTAdditionalDataSearchDelegate {
    let searchAdditionalData = TTAdditionalDataSearch()
    let reverseGeocoder = TTReverseGeocoder()
    var geocoderResult = "Loading..."
    var annotation: TTAnnotation!
    var entityType: String = "Country"

    override func onMapReady() {
        self.mapView.setLanguage("NGT")
    }

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Country", "Municipality"], selectedID: 0)
    }

    override func setupInitialCameraPosition() {
        mapView.center(on: TTCoordinate.LODZ(), withZoom: 3.2)
    }

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        removeAllAnnotationAndOverlays()
        switch ID {
        case 1:
            self.entityType = "Municipality"
        default:
            self.entityType = "Country"
        }
    }

    override func setupMap() {
        super.setupMap()
        mapView.delegate = self
        reverseGeocoder.delegate = self
        searchAdditionalData.delegate = self
        mapView.annotationManager.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupEtaView()
        etaView.update(text: "Drop a pin to get a polygon", icon: UIImage(named: "info_small")!)
    }

    // MARK: Example

    func resolveAddressForCoordinates(_ coordinate: CLLocationCoordinate2D) {
        let query = TTReverseGeocoderQueryBuilder.create(with: coordinate).withEntityType(entityType)
            .build()
        reverseGeocoder.reverseGeocoder(with: query)
    }

    // MARK: TTMapViewDelegate

    func mapView(_ mapView: TTMapView, didLongPress coordinate: CLLocationCoordinate2D) {
        removeAllAnnotationAndOverlays()
        annotation = TTAnnotation(coordinate: coordinate)
        mapView.annotationManager.add(annotation)
        resolveAddressForCoordinates(coordinate)
    }

    // MARK: TTAnnotationDelegate

    func annotationManager(_: TTAnnotationManager, viewForSelectedAnnotation _: TTAnnotation) -> UIView & TTCalloutView {
        return TTCalloutOutlineView(text: geocoderResult)
    }

    // MARK: TTReverseGeocoderDelegate

    func reverseGeocoder(_: TTReverseGeocoder, completedWith response: TTReverseGeocoderResponse) {
        progress.show()
        if let reverseGeocoderAddress = response.result.addresses.first {
            if let freeFormAddress = reverseGeocoderAddress.address.freeformAddress {
                geocoderResult = freeFormAddress
            } else {
                geocoderResult = "Cant resolve address"
            }
            mapView.annotationManager.select(annotation)
        }

        let geometriesZoom = entityType == "Country" ? TTGeometriesZoomByEntityType.COUNTRY() : TTGeometriesZoomByEntityType.MUNICIPALITY()

        guard let address = response.result.addresses.first else { return }
        guard let additionalDataSources = address.additionalDataSources else { return }
        guard let geometryDataSource = additionalDataSources.geometryDataSource else { return }

        let query = TTAdditionalDataSearchQueryBuilder.create(with: geometryDataSource)
            .withGeometriesZoom(geometriesZoom)
            .build()

        searchAdditionalData.additionalDataSearch(with: query)
    }

    func reverseGeocoder(_: TTReverseGeocoder, failedWithError error: TTResponseError) {
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

    func removeAllAnnotationAndOverlays() {
        mapView.annotationManager.removeAllAnnotations()
        mapView.annotationManager.removeAllOverlays()
    }
}
