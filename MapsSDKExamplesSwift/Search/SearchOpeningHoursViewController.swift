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

import MapsSDKExamplesVC
import TomTomOnlineSDKSearch
import UIKit

class SearchOpeningHoursViewController: MapBaseViewController {
    let search = TTSearch(key: Key.Search)

    fileprivate func executeQuery() {
        let query = TTSearchQueryBuilder.create(withTerm: "Petrol station")
            .withPosition(TTCoordinate.AMSTERDAM())
            .withLang("en-GB")
            .withOpeningHours(.nextSevenDays)
            .build()

        search.search(with: query) { [weak self] response, _ in
            guard let self = self else { return }

            guard let response = response else {
                return
            }

            let annotations = response
                .results
                .filter { $0.poi?.openingHours != nil }
                .map { SearchResultAnnotation(result: $0) }

            self.mapView.annotationManager.add(annotations)
            self.mapView.zoomToAllAnnotations()
        }
    }

    override func onMapReady() {
        super.onMapReady()
        self.mapView.annotationManager.delegate = self
        executeQuery()
    }
}

extension SearchOpeningHoursViewController: TTAnnotationDelegate {
    func annotationManager(_: TTAnnotationManager, viewForSelectedAnnotation selectedAnnotation: TTAnnotation) -> UIView & TTCalloutView {
        guard let selectedAnnotation = selectedAnnotation as? SearchResultAnnotation else {
            return TTCalloutOutlineView(text: "-")
        }
        let text = selectedAnnotation.result.poi?.openingHours?.humanReadableHours() ?? "-"
        let title = selectedAnnotation.result.poi?.name ?? "-"
        let view = MultiLineCalloutView(text: text, title: title)
        return TTCalloutOutlineView(uiView: view)
    }

    func annotationManager(_: TTAnnotationManager, annotationSelected annotation: TTAnnotation) {
        mapView.center(on: annotation.coordinate)
    }
}
