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
import TomTomOnlineSDKSearch
import UIKit

extension TTAutocompleteSegment: AutoCompleteBarModel {
    public var subTitle: String {
        switch type {
        case .brand:
            return "Suggested brand"
        case .category:
            return "Suggested category"
        case .plainText:
            return "Suggested plain text"
        }
    }

    public var title: String {
        return value ?? "-"
    }
}

class SearchAutocompleteViewController: BaseViewController {
    lazy var autocompleteBar: AutoCompleteBar = {
        let bar = AutoCompleteBar()
        bar.delegate = self
        return bar
    }()

    lazy var searchAPI = TTSearch(key: Key.Search)

    lazy var mapView: TTMapView = {
        let defaultStyle = TTMapStyleDefaultConfiguration()
        var builder = TTMapConfigurationBuilder.create().withMapStyleConfiguration(defaultStyle)
        let centerOnPoint = TTCenterOnPointBuilder.create(withCenter: TTCoordinate.AMSTERDAM()).withZoom(9).build()
        builder = builder.withViewportTransform(centerOnPoint)
        let mapView = TTMapView(frame: .zero, mapConfiguration: builder.withMapKey(Key.Map).withTrafficKey(Key.Traffic).build())
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.annotationManager.delegate = self
        return mapView
    }()

    lazy var autocomplete = TTAutocomplete(key: Key.Search)

    override func loadView() {
        super.loadView()
        view.addSubview(mapView)
        view.addSubview(autocompleteBar)

        let topOffset: CGFloat = 50

        if #available(iOS 11.0, *) {
            autocompleteBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topOffset).isActive = true
        } else {
            autocompleteBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: topOffset).isActive = true
        }

        autocompleteBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        autocompleteBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
}

extension SearchAutocompleteViewController: AutoCompleteBarDelegate {
    func autoCompleteBarCancelButtonClicked(bar: AutoCompleteBar) {
        bar.data = []
    }

    func autoCompleteBar(bar _: AutoCompleteBar, didSelect item: AutoCompleteBarModel, withText _: String) {
        guard let item = item as? TTAutocompleteSegment else {
            return
        }

        let searchTerm = item.title

        var builder = TTSearchQueryBuilder
            .create(withTerm: searchTerm)
            .withPosition(TTCoordinate.AMSTERDAM(),
                          withRadius: 10000)

        switch item.type {
        case .brand:
            builder = builder.withBrandSet(searchTerm)
        case .category:
            builder = builder.withCategory(true)
        case .plainText:
            break
        }

        searchAPI.search(with: builder.build()) { [weak self] response, _ in
            guard let self = self else { return }

            guard let response = response else {
                return
            }

            let result = response.results.map { SearchResultAnnotation(result: $0) }
            self.autocompleteBar.data = []
            self.mapView.annotationManager.removeAllAnnotations()
            self.mapView.annotationManager.add(result)
            self.mapView.zoom(to: result)
        }
    }

    public func autoCompleteBar(bar _: AutoCompleteBar, textDidChange text: String) {
        let builder = TTAutocompleteQueryBuilder.create(withTerm: text, withLanguage: "en-GB")
        builder.withCountry("NL").withLimit(10)
        builder.withPosition(TTCoordinate.AMSTERDAM(), withRadius: 10000)
        builder.withResultType(.empty)
        let query = builder.build()

        autocomplete.request(with: query) { [weak self] response, _ in
            guard let self = self else { return }
            if let response = response {
                let data = response.results
                    .compactMap { $0.segments }
                    .flatMap { $0 }
                    .map { $0 }
                self.autocompleteBar.data = data
            }
        }
    }
}

extension SearchAutocompleteViewController: TTAnnotationDelegate {
    func annotationManager(_: TTAnnotationManager, viewForSelectedAnnotation selectedAnnotation: TTAnnotation) -> UIView & TTCalloutView {
        guard let selectedAnnotation = selectedAnnotation as? SearchResultAnnotation else {
            return TTCalloutOutlineView(text: "-")
        }

        return TTCalloutOutlineView(text: selectedAnnotation.result.poi?.name ?? "-")
    }
}
