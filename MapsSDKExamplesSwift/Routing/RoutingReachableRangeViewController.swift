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

class RoutingReachableRangeViewController: RoutingBaseViewController, TTReachableRangeDelegate {
    let reachabeRange = TTReachableRange()
    let queryFactory = ReachableRangeQueryFactory()

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Combustion", "Electric", "Time - 2h"], selectedID: -1)
    }

    override func setupCenterOnWillHappen() {
        mapView.center(on: TTCoordinate.AMSTERDAM(), withZoom: 10)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reachabeRange.delegate = self
    }

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        mapView.annotationManager.removeAllOverlays()
        progress.show()
        switch ID {
        case 2:
            displayReachableRangeIn2hTime()
        case 1:
            displayReachableRangeForElectric()
        default:
            displayReachableRangeForCombustion()
        }
    }

    // MARK: Examples

    func displayReachableRangeForCombustion() {
        reachabeRange.find(with: queryFactory.createReachableRangeQueryForCombustion())
    }

    func displayReachableRangeForElectric() {
        reachabeRange.find(with: queryFactory.createReachableRangeQueryForElectric())
    }

    func displayReachableRangeIn2hTime() {
        reachabeRange.find(with: queryFactory.createReachableRangeQueryForElectricLimitTo2Hours())
    }

    // MARK: TTReachableRangeDelegate

    func reachableRange(_: TTReachableRange, completedWithResult response: TTReachableRangeResponse) {
        progress.hide()
        var coordinates: [CLLocationCoordinate2D] = []
        for i in 0 ..< response.result.boundriesCount {
            coordinates.append(response.result.boundry(at: i))
        }

        let polygon = TTPolygon(coordinates: &coordinates, count: UInt(coordinates.count), opacity: 1, color: TTColor.RedSemiTransparent(), colorOutline: TTColor.RedSemiTransparent())
        mapView.annotationManager.add(polygon)
        mapView.zoom(to: polygon)
    }


    func reachableRange(_: TTReachableRange, completedWith responseError: TTResponseError) {
        handleError(responseError)
    }

}
