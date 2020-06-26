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

class SearchReverseGeocodingViewController: MapBaseViewController, TTMapViewDelegate, TTAnnotationDelegate, TTReverseGeocoderDelegate {
    let reverseGeocoder = TTReverseGeocoder(key: Key.Search)
    var geocoderResult = "Loading..."
    var annotation: TTAnnotation!

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: [], selectedID: -1)
    }

    override func setupMap() {
        super.setupMap()
        mapView.delegate = self
        reverseGeocoder.delegate = self
        mapView.annotationManager.delegate = self

        guard let icon = UIImage(named: "info_small") else {
            return
        }

        setupEtaView()
        etaView.update(text: "Drop a pin on map", icon: icon)
    }

    // MARK: Example

    func resolveAddressForCoordinates(_ coordinate: CLLocationCoordinate2D) {
        let query = TTReverseGeocoderQueryBuilder.create(with: coordinate)
            .build()
        reverseGeocoder.reverseGeocoder(with: query)
    }

    // MARK: TTMapViewDelegate

    func mapView(_ mapView: TTMapView, didLongPress coordinate: CLLocationCoordinate2D) {
        mapView.annotationManager.removeAllAnnotations()
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
        if let reverseGeocoderAddress = response.result.addresses.first {
            if let freeFormAddress = reverseGeocoderAddress.address.freeformAddress {
                geocoderResult = freeFormAddress
            } else {
                geocoderResult = "Cant resolve address"
            }
            mapView.annotationManager.select(annotation)
        }
    }

    func reverseGeocoder(_: TTReverseGeocoder, failedWithError error: TTResponseError) {
        handleError(error)
    }
}
