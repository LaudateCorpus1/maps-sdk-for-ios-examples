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

import MapsSDKExamplesCommon
import MapsSDKExamplesVC
import TomTomOnlineSDKMaps
import TomTomOnlineSDKSearch
import UIKit

class SearchPoiDetailsAndPhotosViewController: MapBaseViewController {
    let searchAPI = TTSearch(key: Key.Search)

    let poiDetailsAPI = PoiDetailsService(key: Key.Search)
    let poiPhotosAPI: PoiPhotosService = .init(apiKey: Key.Search)

    override func onMapReady() {
        super.onMapReady()
        self.mapView.annotationManager.delegate = self
        progress.show()
        searchPoi()
    }

    func searchPoi() {
        let searchQuery = TTSearchQueryBuilder.create(withTerm: "Restaurant").withPosition(TTCoordinate.AMSTERDAM()).withLimit(200).withOpeningHours(.nextSevenDays).build()
        searchAPI.search(with: searchQuery) { [weak self] response, _ in

            guard let self = self else { return }
            self.progress.hide()
            guard let response = response else {
                return
            }
            let annotations = response.results.map { SearchResultAnnotation(result: $0) }
            self.mapView.annotationManager.add(annotations)
            self.mapView.zoom(to: annotations)
        }
    }
}

extension SearchPoiDetailsAndPhotosViewController: TTAnnotationDelegate {
    fileprivate func requestPhotos(_ poiDetailsResponse: PoiDetails, poiAnnotation: SearchResultAnnotation) {
        // POI PHOTOS REQUEST
        let photoIdArray = poiDetailsResponse.photos.map { PoiPhoto(photoID: $0.photoID) }
        self.poiPhotosAPI.get(photos: photoIdArray) { [weak self] images, error in

            guard let self = self else { return }
            self.progress.hide()

            guard let images = images, error == nil else {
                self.present(TTErrorUIAlertController.create(), animated: true, completion: nil)
                return
            }
            guard let model = PoiDetailsModel(photos: images,
                                              annotationData: poiAnnotation,
                                              poiDetails: poiDetailsResponse) else { return }

            let vc = PoiDetailsViewController(model: model)
            self.present(vc, animated: true, completion: nil)
        }
    }

    func annotationManager(_: TTAnnotationManager, annotationSelected annotation: TTAnnotation) {
        mapView.center(on: annotation.coordinate)

        guard let poiAnnotation = annotation as? SearchResultAnnotation,
              let additionalDataSources = poiAnnotation.result.additionalDataSources
        else {
            return
        }
        guard let dataSourceID = additionalDataSources.poiDetailsDataSources.first(where: { $0.sourceName == "Foursquare" })?.dataSourceID else {
            return
        }

        progress.show()

        let poiDetailsSpecification = AnnotationPoiDetailsSpecification(poiDetailsID: dataSourceID as String)
        poiDetailsAPI.fetchPoiDetails(specification: poiDetailsSpecification) { [weak self] poiDetailsResponse, error in

            guard let self = self else { return }
            guard let poiDetailsResponse = poiDetailsResponse, error == nil else {
                self.progress.hide()
                self.present(TTErrorUIAlertController.create(), animated: true, completion: nil)
                return
            }
            self.requestPhotos(poiDetailsResponse, poiAnnotation: poiAnnotation)
        }
    }
}
