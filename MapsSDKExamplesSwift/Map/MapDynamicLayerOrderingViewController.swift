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
import TomTomOnlineSDKRouting
import UIKit

class MapDynamicLayerOrderingViewController: MapBaseViewController, TTRouteResponseDelegate {
    let GEOJSON_SOURCE = "geojson-source"

    var currentStyle: TTMapStyle!
    let routePlanner = TTRoute(key: Key.Routing)

    override func viewDidLoad() {
        super.viewDidLoad()
        progress.show()
    }

    override func setupInitialCameraPosition() {
        mapView.center(on: TTCoordinate.SAN_JOSE_9RD(), withZoom: 7.5)
    }

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Images", "GeoJSON", "Roads"], selectedID: 0)
    }

    override func onMapReady() {
        routePlanner.delegate = self
        planRoute()
        currentStyle = mapView.styleManager.currentStyle

        let path = Bundle.main.path(forResource: "layer_road", ofType: "json")
        let layerJSON = try! String(contentsOfFile: path!, encoding: .utf8)
        let layerMap = TTMapLayer.create(withStyleJSON: layerJSON, withMap: mapView)
        layerMap?.visibility = .visible
        currentStyle.add(layerMap!)

        addImagesSource()
    }

    private func planRoute() {
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.SANTA_CRUZ(), andOrig: TTCoordinate.SAN_FRANCISCO()).build()
        routePlanner.plan(with: query)
    }

    private func addImagesSource() {
        addImage(index: 1, coordinates: TTCoordinate.SAN_JOSE_IMG1(), uiImage: UIImage(named: "img1")!)
        addImage(index: 2, coordinates: TTCoordinate.SAN_JOSE_IMG2(), uiImage: UIImage(named: "img2")!)
        addImage(index: 3, coordinates: TTCoordinate.SAN_JOSE_IMG3(), uiImage: UIImage(named: "img3")!)
    }

    private func addImage(index: Int, coordinates: CLLocationCoordinate2D, uiImage: UIImage) {
        let quad = quadWithDelta(coordinate: coordinates, delta: 0.25)
        let sourceMap = TTMapImageSource.create(withID: "img-source-\(index)", image: uiImage, coordinates: quad)
        currentStyle.add(sourceMap)

        let layerMap = TTMapLayer.createRaster(withID: "img-id-\(index)", withSourceID: "img-source-\(index)", withMap: mapView)
        currentStyle.add(layerMap!)
    }

    // MARK: TTRouteResponseDelegate

    func route(_ route: TTRoute, completedWith result: TTRouteResult) {
        let route = result.routes[0]
        let geoJsonLine = TTGeoJSONLineString(coordinatesData: route.coordinatesData(), with: nil)
        let geoJsonSource = TTMapGeoJSONSource.create(withID: GEOJSON_SOURCE)
        geoJsonSource.setGeoJSONObject(geoJsonLine)
        currentStyle.add(geoJsonSource)
        progress.hide()
    }

    func route(_: TTRoute, completedWith responseError: TTResponseError) {
        handleError(responseError)
    }

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        switch ID {
        case 2:
            let layersRoads = currentStyle.getLayersBySourceLayerRegexs([".*[rR]oad.*", ".*[mM]otorway.*"])
            layersRoads.forEach { currentStyle.moveLayer(toFront: $0) }
        case 1:
            let layerRoute = currentStyle.getLayerByID("layer-line-id")
            currentStyle.moveLayer(toFront: layerRoute!)
        default:
            let layersImages = currentStyle.getLayersByRegex("img-id.*")
            layersImages.forEach { currentStyle.moveLayer(toFront: $0) }
        }
    }

    // MARK: private

    private func quadWithDelta(coordinate: CLLocationCoordinate2D, delta: Double) -> TTLatLngQuad {
        return TTLatLngQuad(topLeft: CLLocationCoordinate2D(latitude: coordinate.latitude + delta / 2, longitude: coordinate.longitude - delta),
                            withTopRight: CLLocationCoordinate2D(latitude: coordinate.latitude + delta / 2, longitude: coordinate.longitude + delta),
                            withBottomRight: CLLocationCoordinate2D(latitude: coordinate.latitude - delta / 2, longitude: coordinate.longitude - delta),
                            withBottomLeft: CLLocationCoordinate2D(latitude: coordinate.latitude - delta / 2, longitude: coordinate.longitude + delta))
    }
}
