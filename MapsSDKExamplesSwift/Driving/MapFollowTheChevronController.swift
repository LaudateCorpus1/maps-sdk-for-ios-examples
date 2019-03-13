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
import TomTomOnlineSDKMaps

class MapFollowTheChevronController: RoutingBaseViewController, TTRouteResponseDelegate {

    let routePlanner = TTRoute()
    var waypoints = [TTCoordinate.LODZ_SREBRZYNSKA_WAYPOINT_A(),
                     TTCoordinate.LODZ_SREBRZYNSKA_WAYPOINT_B(),
                     TTCoordinate.LODZ_SREBRZYNSKA_WAYPOINT_C()]

    var source: MapFollowTheChevronSource?
    private var chevron: TTChevronObject?
    
    override func setupCenterOnWillHappen() {
        mapView.center(on: TTCoordinate.LODZ(), withZoom: 10)
    }
    
    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Start tracking", "Stop tracking"], selectedID: -1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        routePlanner.delegate = self
        mapView.contentInset = TTCamera.MAP_DEFAULT_INSETS();
        progress.show()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        source?.deactivate()
        super.viewWillDisappear(animated)
    }

    override func onMapReady() {
        super.onMapReady()
        createRoute()
    }

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        switch ID {
        case 1:
            stop()
        default:
            start()
        }
    }

    func createRoute() {
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.LODZ_SREBRZYNSKA_STOP(), andOrig: TTCoordinate.LODZ_SREBRZYNSKA_START())
            .withWayPoints(&waypoints, count: UInt(waypoints.count))
            .build()
        routePlanner.plan(with: query)
    }

    func createChevron() {
        self.mapView.isShowsUserLocation = false
        let animation = TTChevronAnimationOptionsBuilder.create(withAnimatedCornerRounding: false).build()
        chevron = TTChevronObject(normalImage: TTChevronObject.defaultNormalImage(), withDimmedImage: TTChevronObject.defaultDimmedImage(), with: animation)
    }

    func start() {
        let camera = TTCameraPositionBuilder.create(withCameraPosition:TTCoordinate.LODZ_SREBRZYNSKA_START())
            .withAnimationDuration(TTCamera.ANIMATION_TIME())
            .withBearing(TTCamera.BEARING_START())
            .withPitch(TTCamera.DEFAULT_MAP_PITCH_LEVEL_FOR_DRIVING())
            .withZoom(Double(TTCamera.DEFAULT_MAP_ZOOM_LEVEL_FOR_DRIVING()))
            .build()
        mapView.setCameraPosition(camera)

        guard let chevron = self.chevron else {return}
        mapView.trackingManager.setBearingSmoothingFilter(TTTrackingManagerDefault.bearingSmoothFactor())
        mapView.trackingManager.start(chevron)
    }

    func stop() {
        mapView.trackingManager.stop(chevron!)
        displayRouteOverview()
    }
    
    //MARK: TTRouteResponseDelegate
    
    func route(_ route: TTRoute, completedWith result: TTRouteResult) {
        guard let plannedRoute = result.routes.first else {
            return
        }
        let mapRoute = TTMapRoute(coordinatesData: plannedRoute,
                                  with: TTMapRouteStyle.defaultActive(),
                                  imageStart: TTMapRoute.defaultImageDeparture(),
                                  imageEnd: TTMapRoute.defaultImageDestination())
        mapView.routeManager.add(mapRoute)
        mapView.routeManager.bring(toFrontRoute: mapRoute)
        etaView.show(summary: plannedRoute.summary, style: .plain)
        displayRouteOverview()
        progress.hide()

        createChevron()
        mapView.trackingManager.add(self.chevron!)
        source = MapFollowTheChevronSource(trackingManager: self.mapView.trackingManager, trackingObject: self.chevron!, route: mapRoute)
        source?.activate()
    }
    
    func route(_ route: TTRoute, completedWith responseError: TTResponseError) {
        handleError(responseError)
    }

}
