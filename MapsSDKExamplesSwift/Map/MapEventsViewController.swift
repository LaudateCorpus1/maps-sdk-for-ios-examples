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

class MapEventsViewController: MapBaseViewController, TTMapViewDelegate {
    override func setupMap() {
        super.setupMap()
        mapView.delegate = self
    }

    private func toast(message: String, coordinate: CLLocationCoordinate2D) {
        toast.toast(message: "\(message): " +
            String(format: "%.5f", coordinate.latitude) + ", " +
            String(format: "%.5f", coordinate.longitude))
    }

    // MARK: TTMapViewDelegate

    func mapView(_: TTMapView, didDoubleTap coordinate: CLLocationCoordinate2D) {
        toast(message: "Double tap", coordinate: coordinate)
    }

    func mapView(_: TTMapView, didSingleTap coordinate: CLLocationCoordinate2D) {
        toast(message: "Single tap", coordinate: coordinate)
    }

    func mapView(_: TTMapView, didLongPress coordinate: CLLocationCoordinate2D) {
        toast(message: "Long press", coordinate: coordinate)
    }

    func mapView(_: TTMapView, didPanning coordinate: CLLocationCoordinate2D, in state: TTMapPanningState) {
        switch state {
        case .begin:
            toast(message: "Panning started", coordinate: coordinate)
        case .changed:
            toast(message: "Panning", coordinate: coordinate)
        case .end:
            toast(message: "Panning finished", coordinate: coordinate)
        @unknown default:
            return
        }
    }

    func mapView(_: TTMapView, onCenterStatusChanged _: TTMapCenteredState) {
    }

    func mapView(_: TTMapView, onCameraChanged _: TTCameraPosition, with _: TTMapCameraChangeState) {
    }
}
