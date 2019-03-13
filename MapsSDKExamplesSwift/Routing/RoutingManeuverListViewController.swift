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

import UIKit
import MapsSDKExamplesCommon
import MapsSDKExamplesVC
import TomTomOnlineSDKRouting

class RoutingManeuverListViewController: TableBaseViewController, TTRouteResponseDelegate {
    
    var locationManager: LocationManager!
    var etaView: ETAWithSegmentsView!
    let routePlanner = TTRoute()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = LocationManager.shared
        locationManager.start()
        routePlanner.delegate = self
        let etaView = ETAWithSegmentsView(frame: CGRect(x: 0, y: 0, width: 0, height: 80))
        self.etaView = etaView
        etaView.segments.selectedSegmentIndex = 0
        tableView.rowHeight = 70
        tableView.tableHeaderView = etaView
        etaView.addTarget(self, action: #selector(languageChanged(sender:)))
        displayManeuverList(language: "en-GB")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stop()
    }

    @objc func languageChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 3:
            displayManeuverList(language: "fr-FR")
        case 2:
            displayManeuverList(language: "es-ES")
        case 1:
            displayManeuverList(language: "de-DE")
        default:
            displayManeuverList(language: "en-GB")
        }
    }
    
    func displayManeuverList(language: String) {
        progress.show()
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.BERLIN(), andOrig: TTCoordinate.AMSTERDAM())
            .withInstructionsType(.text)
            .withLang(language)
            .build()
        routePlanner.plan(with: query)
    }
    
    //MARK: TTRouteResponseDelegate
    
    func route(_ route: TTRoute, completedWith result: TTRouteResult) {
        guard let plannedRoute = result.routes.first else {
            return
        }
        etaView.show(summary: plannedRoute.summary)
        displayResults(plannedRoute.guidance.instructions)
        progress.hide()
    }
    
    func route(_ route: TTRoute, completedWith responseError: TTResponseError) {
        handleError(responseError)
    }
}
