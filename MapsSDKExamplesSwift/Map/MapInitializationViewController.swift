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
import UIKit

class MapInitializationViewController: MapBaseViewController, TTMapViewDelegate {
    var map: TTMapView?
    var placeholderView = UIView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: OptionsViewDelegate

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Bounding box", "Starting point"], selectedID: 0)
    }

    override func setupMap() {
        setupPlaceholderViewConstraint()
        mapConfigurationWithBoundingBox()
    }

    func setupPlaceholderViewConstraint() {
        view.addSubview(placeholderView)
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        placeholderView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        placeholderView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        placeholderView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
    }

    func setupMapViewConstraint() {
        guard let map = map else {
            return
        }
        placeholderView.addSubview(map)
        map.translatesAutoresizingMaskIntoConstraints = false
        map.topAnchor.constraint(equalTo: self.placeholderView.topAnchor, constant: 0).isActive = true
        map.bottomAnchor.constraint(equalTo: self.placeholderView.bottomAnchor, constant: 0).isActive = true
        map.leftAnchor.constraint(equalTo: self.placeholderView.leftAnchor, constant: 0).isActive = true
        map.rightAnchor.constraint(equalTo: self.placeholderView.rightAnchor, constant: 0).isActive = true
        self.map?.delegate = self
    }

    override func displayExample(withID ID: Int, on: Bool) {
        progress.show()
        super.displayExample(withID: ID, on: on)
        switch ID {
        case 1:
            mapConfigurationWithStartingPoint()
        default:
            mapConfigurationWithBoundingBox()
        }
    }

    // MARK: Examples

    func mapConfigurationWithBoundingBox() {
        self.map?.removeFromSuperview()
        self.map = nil

        let transform = TTCenterOnGeometryBuilder.create(withGeometry: [
            .init(TTCoordinate.AMSTERDAM_BOUNDINGBOX_LT()),
            .init(TTCoordinate.AMSTERDAM_BOUNDINGBOX_RT()),
            .init(TTCoordinate.AMSTERDAM_BOUNDINGBOX_LB()),
            .init(TTCoordinate.AMSTERDAM_BOUNDINGBOX_RB()),
        ], withPadding: .zero)
            .withPitch(30)
            .withBearing(-90)
            .build()
        let config = TTMapConfigurationBuilder.create().withViewportTransform(transform)
        let position = TTLogoPosition(verticalPosition: .top, horizontalPosition: .right, verticalOffset: 35, horizontalOffset: -170)
        config.withTomTomLogoPosition(position)
        map = TTMapView(frame: self.view.bounds, mapConfiguration: config.build())
        setupMapViewConstraint()
    }

    func mapConfigurationWithStartingPoint() {
        self.map?.removeFromSuperview()
        self.map = nil
        let builder = TTMapConfigurationBuilder.create()
        let transform = TTCenterOnPointBuilder.create(withCenter: TTCoordinate.LODZ_ZEROMSKIEGO()).withZoom(15).build()
        let config = builder.withViewportTransform(transform)
        let position = TTLogoPosition(verticalPosition: .bottom, horizontalPosition: .right, verticalOffset: -65, horizontalOffset: -170)
        config.withTomTomLogoPosition(position)
        map = TTMapView(frame: self.view.bounds, mapConfiguration: config.build())
        setupMapViewConstraint()
    }

    func onMapReady(_: TTMapView) {
        progress.hide()
    }
}
