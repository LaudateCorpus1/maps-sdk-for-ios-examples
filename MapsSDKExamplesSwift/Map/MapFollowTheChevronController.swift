/**
 * Copyright (c) 2018 TomTom N.V. All rights reserved.
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

class MapFollowTheChevronController: MapBaseViewController {

    let routePlanner = TTRoute()
    var waypoints = [TTCoordinate.LODZ_SREBRZYNSKA_WAYPOINT_A(),
                     TTCoordinate.LODZ_SREBRZYNSKA_WAYPOINT_B(),
                     TTCoordinate.LODZ_SREBRZYNSKA_WAYPOINT_C()]
    var route:TTMapRoute?
    var source: MapFollowTheChevronSource?

    private var chevron: TTChevronObject?

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Start tracking", "Stop tracking"], selectedID: -1)
    }

    override func onMapReady() {
        super.onMapReady()
        self.createRoute()
    }

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        switch ID {
        case 0:
            start()
        default:
            stop()
        }
    }

    func createRoute() {
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.LODZ_SREBRZYNSKA_STOP(), andOrig: TTCoordinate.LODZ_SREBRZYNSKA_START())
            .withWayPoints(&waypoints, count: UInt(waypoints.count))
            .build()
        routePlanner.plan(with: query) { (routeResult, responseError) in
            let plannedRoute = routeResult?.routes.first
            if (plannedRoute != nil) {
                self.displayPlannedRoute(plannedRoute: plannedRoute!)
                self.createChevron()
                self.mapView.trackingManager.add(self.chevron!)
                self.source = MapFollowTheChevronSource(trackingManager: self.mapView.trackingManager, trackingObject: self.chevron!, route: self.route!)
                self.source?.activate()
            }
        }
    }

    func displayPlannedRoute(plannedRoute: TTFullRoute) {
        self.route = TTMapRoute(coordinatesData: plannedRoute,
                                imageStart: TTMapRoute.defaultImageDeparture(),
                                imageEnd: TTMapRoute.defaultImageDestination())
        OperationQueue.main.addOperation({
            self.mapView.routeManager.add(self.route!)
            self.mapView.routeManager.showRouteOverview(self.route!)
            self.mapView.routeManager.routes.first?.isActive = true
            self.showRoute()
        })
    }

    func createChevron() {
        self.mapView.isShowsUserLocation = false
        chevron = TTChevronObject(normalImage:TTChevronObject.defaultNormalImage(), withNormalImageName: "active", withDimmedImage: TTChevronObject.defaultDimmedImage(), withDimmedImageName: "inactive");

    }

    func start() {
        let camera = TTCameraPosition(camerPosition: TTCoordinate.LODZ_SREBRZYNSKA_START(),
                                      withAnimationDuration: TTCamera.ANIMATION_TIME(),
                                      withBearing: TTCamera.BEARING_START(),
                                      withPitch: TTCamera.DEFAULT_MAP_PITCH_LEVEL_FOR_DRIVING(),
                                      withZoom: TTCamera.DEFAULT_MAP_ZOOM_LEVEL_FOR_DRIVING())
        mapView.setCameraPosition(camera)

        mapView.trackingManager.start(chevron!)
    }

    func stop() {
        mapView.trackingManager.stop(chevron!)

        showRoute()
    }

    func showRoute() {
        if (route != nil) {
            mapView.contentInset = TTCamera.MAP_DEFAULT_INSETS();
            mapView.routeManager.showRouteOverview(self.route!)
        }
    }
}
