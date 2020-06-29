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

class MapVectorTrafficViewController: MapBaseViewController {
    override func setupInitialCameraPosition() {
        mapView.center(on: TTCoordinate.LONDON(), withZoom: 12)
    }

    override func getOptionsView() -> OptionsView {
        return OptionsViewMultiSelectWithReset(labels: ["Incidents", "Flow", "No traffic"], selectedID: 2)
    }

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        switch ID {
        case 2:
            hideIncidents()
            hideFlow()
        case 1:
            if on {
                displayFlow()
            } else {
                hideFlow()
            }
        default:
            if on {
                displayIncidents()
            } else {
                hideIncidents()
            }
        }
    }

    // MARK: Examples

    func displayIncidents() {
        mapView.trafficIncidentsOn = true
    }

    func hideIncidents() {
        mapView.trafficIncidentsOn = false
    }

    func displayFlow() {
        mapView.trafficFlowOn = true
    }

    func hideFlow() {
        mapView.trafficFlowOn = false
    }
}
