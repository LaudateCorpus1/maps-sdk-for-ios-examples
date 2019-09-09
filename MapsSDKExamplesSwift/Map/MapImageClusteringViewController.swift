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

import Foundation
import MapsSDKExamplesCommon
import MapsSDKExamplesVC
import TomTomOnlineSDKMaps

class MapImageClusteringViewController: MapBaseViewController {
    var currentStyle: TTMapStyle!

    override func onMapReady() {
        currentStyle = mapView.styleManager.currentStyle
        addStyleImages()
        setupClusterStyle()
    }

    override func setupCenterOnWillHappen() {
        mapView.center(on: TTCoordinate.AMSTERDAM_CIRCLE_CENTER(), withZoom: 9)
    }

    private func setupClusterStyle() {
        let path = Bundle.main.path(forResource: "ic_app_test_source", ofType: "json")
        let geojsonJSON = try! String(contentsOfFile: path!, encoding: .utf8)
        let sourceMap = TTMapSource.create(withSourceJSON: geojsonJSON)
        currentStyle.add(sourceMap!)

        addLayerWithName("ic_app_test_layer", to: mapView, and: currentStyle)
        addLayerWithName("ic_app_test_layer_cluster", to: mapView, and: currentStyle)
        addLayerWithName("ic_app_test_layer_symbol_count", to: mapView, and: currentStyle)
    }

    func addLayerWithName(_ jsonStyleName: String, to map: TTMapView, and style: TTMapStyle) {
        guard let path = Bundle.main.path(forResource: jsonStyleName, ofType: "json") else {
            print("Failed to find path for name: \(jsonStyleName).json")
            return
        }
        guard let layerContentJSONString = try? String(contentsOfFile: path, encoding: .utf8) else {
            print("Failed to read file at path: \(path)")
            return
        }
        guard let mapLayer = TTMapLayer.create(withStyleJSON: layerContentJSONString, withMap: map) else {
            print("Failed to create TTMapLayer from: \(layerContentJSONString)")
            return
        }
        style.add(mapLayer)
    }

    private func addStyleImages() {
        let jetAirPlainLanding = UIImage(named: "jet_airplane_landing")
        currentStyle.add(jetAirPlainLanding!, withID: "jet_airplane_landing")

        let amsterdam = UIImage(named: "amsterdam_netherlands")
        let amsterdam2 = UIImage(named: "amsterdam2")
        let road_with_traffic = UIImage(named: "road_with_traffic")
        let tunnel = UIImage(named: "tunnel")
        let gasStation = UIImage(named: "gas_station")
        let photo4 = UIImage(named: "photo4")
        let traffic_light = UIImage(named: "traffic_light")
        let clusterBg = UIImage(named: "ic_cluster")

        currentStyle.add(jetAirPlainLanding!, withID: "jet_airplane_landing")
        currentStyle.add(amsterdam!, withID: "amsterdam_netherlands")
        currentStyle.add(amsterdam2!, withID: "amsterdam2")
        currentStyle.add(road_with_traffic!, withID: "road_with_traffic")
        currentStyle.add(tunnel!, withID: "tunnel")
        currentStyle.add(gasStation!, withID: "gas_station")
        currentStyle.add(photo4!, withID: "photo4")
        currentStyle.add(traffic_light!, withID: "traffic_light")
        currentStyle.add(clusterBg!, withID: "ic_cluster")
    }
}
