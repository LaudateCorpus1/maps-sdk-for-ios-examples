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
import UIKit

class MapInteractiveLayersViewController: MapBaseViewController, TTMapViewDelegate, TTMapViewCameraDelegate {
    var currentStyle: TTMapStyle!

    override func setupCenterOnWillHappen() {
        mapView.center(on: TTCoordinate.LONDON(), withZoom: 9)
    }

    override func onMapReady() {
        currentStyle = mapView.styleManager.currentStyle
        mapView.delegate = self
        addGeoJSONSource()
        let geoLayer = currentStyle?.getLayerByID("IL-test-source")
        geoLayer?.visibility = .visible
        DispatchQueue.main.asyncAfter(deadline: .now() + toast.delayTime) { [weak self] in
            self?.displayFeaturesToast()
        }
    }

    func addGeoJSONSource() {
        let path = Bundle.main.path(forResource: "interactive_layers_data", ofType: "json")
        let geojsonJSON = try! String(contentsOfFile: path!, encoding: .utf8)
        let sourceMap = TTMapSource.create(withSourceJSON: geojsonJSON)
        currentStyle.add(sourceMap!)

        let outlinePath = Bundle.main.path(forResource: "interactive_layers_outline_layer", ofType: "json")
        let outlineLayerJson = try! String(contentsOfFile: outlinePath!, encoding: .utf8)
        let outlineLayer = TTMapLayer.create(withStyleJSON: outlineLayerJson, withMap: mapView)
        currentStyle.add(outlineLayer!)

        let fillPath = Bundle.main.path(forResource: "interactive_layers_fill_layer", ofType: "json")
        let fillLayerJson = try! String(contentsOfFile: fillPath!, encoding: .utf8)
        let fillLayer = TTMapLayer.create(withStyleJSON: fillLayerJson, withMap: mapView)
        currentStyle.add(fillLayer!)
    }

    func mapView(_ mapView: TTMapView, didSingleTap coordinate: CLLocationCoordinate2D) {
        let geoJSONFeatures = mapView.features(atCoordinates: coordinate, inStyleLayerIdentifiers: ["IL-test-layer-outline"])
        var message = "Tapped on: "

        if geoJSONFeatures.features.isEmpty {
            message.append("no features.")
        } else {
            message.append(listFeaturesIdsToString(geoJSONFeatureCollection: geoJSONFeatures))
        }

        toast.toast(message: message)
    }

    func mapView(_ mapView: TTMapView, didChangCameraPosition _: TTCameraPosition) {
        displayFeaturesToast()
    }

    func displayFeaturesToast() {
        let geoJSONFeatures = mapView.features(atScreenRect: mapView.bounds, inStyleLayerIdentifiers: ["IL-test-layer-outline"])
        var message = "Features in viewport: "
        if geoJSONFeatures.features.isEmpty {
            message.append("no features.")
        } else {
            message.append(listFeaturesIdsToString(geoJSONFeatureCollection: geoJSONFeatures))
        }

        toast.toast(message: message)
    }

    func listFeaturesIdsToString(geoJSONFeatureCollection: TTGeoJSONFeatureCollection) -> String {
        var list = String()
        var uniqueFeaturesIds = Set<String>()
        for feature in geoJSONFeatureCollection.features {
            uniqueFeaturesIds.insert(feature.id!)
        }
        for id in uniqueFeaturesIds {
            list.append(id + ", ")
        }
        list = String(list.dropLast(2))
        list.append(".")
        return list
    }
}
