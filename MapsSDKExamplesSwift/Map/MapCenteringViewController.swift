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
import UIKit

class MapCenteringViewController: MapBaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        centerOnAmsterdam()
    }

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Amsterdam", "Berlin", "Bounding box"], selectedID: 0)
    }

    override func setupInitialCameraPosition() {}

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        switch ID {
        case 2:
            boundingBoxOnAmsterdam()
        case 1:
            centerOnBerlin()
        default:
            centerOnAmsterdam()
        }
    }

    // MARK: Examples

    func centerOnAmsterdam() {
        let cameraPosition = TTCameraPositionBuilder.create(withCameraPosition: TTCoordinate.AMSTERDAM()).withZoom(10).build()
        mapView.setCameraPosition(cameraPosition)
    }

    func centerOnBerlin() {
        let cameraPosition = TTCameraPositionBuilder.create(withCameraPosition: TTCoordinate.BERLIN()).withZoom(10).build()
        mapView.setCameraPosition(cameraPosition)
    }

    func boundingBoxOnAmsterdam() {
        let boundingBox = TTBoundingBox(topLeft: TTCoordinate.AMSTERDAM_BOUNDINGBOX_LT(), withBottomRight: TTCoordinate.AMSTERDAM_BOUNDINGBOX_RB())
        let cameraPosition = TTCameraBoundingBoxBuilder.create(with: boundingBox!).build()
        mapView.setCameraPosition(cameraPosition)
    }
}
