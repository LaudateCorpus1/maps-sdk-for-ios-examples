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
import TomTomOnlineSDKTraffic
import UIKit

class TrafficIncidentsViewController: TrafficBaseViewController, TTTrafficIncidentsDelegate {
    let traffic = TTTrafficIncidents()

    override func viewDidLoad() {
        super.viewDidLoad()
        traffic.delegate = self
        displayIncidents()
    }

    // MARK: Example

    func displayIncidents() {
        progress.show()
        let bounds = TTLatLngBoundsMake(TTCoordinate.LONDON_TOP_LEFT(), TTCoordinate.LONDON_BOTTOM_RIGHT())
        let query = TTIncidentDetailsQueryBuilder.create(with: .S1, withBoundingBox: bounds, withZoom: 12, withTrafficModelID: "-1")
            .build()
        traffic.incidentDetails(with: query)
    }

    // MARK: TTTrafficIncidentsDelegate

    func incidentDetails(_: TTTrafficIncidents, completedWith response: TTIncidentDetailsResponse) {
        progress.hide()
        displayResults(response.incidents)
    }


    func incidentDetails(_: TTTrafficIncidents, failedWithError error: TTResponseError) {
        handleError(error)
    }
}
