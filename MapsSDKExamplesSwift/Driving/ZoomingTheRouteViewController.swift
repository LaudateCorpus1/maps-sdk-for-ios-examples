/**
 * Copyright (c) 2021 TomTom N.V. All rights reserved.
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

class ZoomingTheRouteViewController: RoutingBaseViewController, TTRouteResponseDelegate {
    let ZOOM_CHANGE_ANIMATION_MILLIS = 300
    let SMALL_SPEED_ZOOM_LEVEL = 19.0
    let MEDIUM_SPEED_ZOOM_LEVEL = 18.0
    let GREATER_SPEED_ZOOM_LEVEL = 17.0
    let BIG_SPEED_ZOOM_LEVEL = 16.0
    let HUGE_SPEED_ZOOM_LEVEL = 14.0
    let SMALL_SPEED_RANGE_IN_KMH = 0.0 ..< 10.0
    let MEDIUM_SPEED_RANGE_IN_KMH = 10.0 ..< 20.0
    let GREATER_SPEED_RANGE_IN_KMH = 20.0 ..< 40.0
    let BIG_SPEED_RANGE_IN_KMH = 40.0 ..< 70.0
    let HUGE_SPEED_RANGE_IN_KMH = 70.0 ..< 120.0
    let routePlanner = TTRoute(key: Key.Routing)
    var waypoints = [TTCoordinate.LODZ_SREBRZYNSKA_WAYPOINT_A(),
                     TTCoordinate.LODZ_SREBRZYNSKA_WAYPOINT_B(),
                     TTCoordinate.LODZ_SREBRZYNSKA_WAYPOINT_C()]

    var source: LocationManagerMock?

    var updateZoom = false
    var chevron: TTChevronObject?

    override func setupInitialCameraPosition() {
        mapView.center(on: TTCoordinate.LODZ(), withZoom: 10)
    }

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Start tracking", "Stop tracking"], selectedID: -1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        routePlanner.delegate = self
        mapView.contentInset = TTCamera.MAP_DEFAULT_INSETS()
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
        updateZoom = true
        chevron!.isHidden = false
        let camera = TTCameraPositionBuilder.create(withCameraPosition: TTCoordinate.LODZ_SREBRZYNSKA_START())
            .withAnimationDuration(TTCamera.ANIMATION_TIME())
            .withBearing(TTCamera.BEARING_START())
            .withPitch(TTCamera.DEFAULT_MAP_PITCH_LEVEL_FOR_DRIVING())
            .withZoom(Double(TTCamera.DEFAULT_MAP_ZOOM_LEVEL_FOR_DRIVING()))
            .build()
        mapView.setCameraPosition(camera)

        guard let chevron = self.chevron else { return }
        mapView.trackingManager.setBearingSmoothingFilter(TTTrackingManagerDefault.bearingSmoothFactor())
        mapView.trackingManager.start(chevron)
    }

    func stop() {
        updateZoom = false
        mapView.trackingManager.stop(chevron!)
        displayRouteOverview()
    }

    // MARK: TTRouteResponseDelegate

    func route(_: TTRoute, completedWith result: TTRouteResult) {
        guard let plannedRoute = result.routes.first else {
            return
        }
        let mapRoute = TTMapRoute(coordinatesData: plannedRoute,
                                  with: TTMapRouteStyle.defaultActive(),
                                  imageStart: TTMapRoute.defaultImageDeparture(),
                                  imageEnd: TTMapRoute.defaultImageDestination())

        mapView.routeManager.add(mapRoute)
        mapView.routeManager.bring(toFrontRoute: mapRoute)
        displayRouteOverview()
        progress.hide()

        createChevron()
        mapView.trackingManager.add(self.chevron!)
        source = LocationManagerMock(route: mapRoute)
        source?.delegate = self
        source?.activate()
    }

    func route(_: TTRoute, completedWith responseError: TTResponseError) {
        handleError(responseError)
    }

    func applyLocation(_ location: CLLocation) {
        mapView.trackingManager.update(chevron!, with: TTLocation(coordinate: location.coordinate, withRadius: location.horizontalAccuracy, withBearing: location.course, withAccuracy: location.horizontalAccuracy))
        updateZoomLevelBaseOnNewLocation(location)
    }

    func updateZoomLevelBaseOnNewLocation(_ location: CLLocation) {
        guard updateZoom else { return }
        var zoom: Double
        switch location.speed {
        case SMALL_SPEED_RANGE_IN_KMH:
            zoom = SMALL_SPEED_ZOOM_LEVEL
        case MEDIUM_SPEED_RANGE_IN_KMH:
            zoom = MEDIUM_SPEED_ZOOM_LEVEL
        case GREATER_SPEED_RANGE_IN_KMH:
            zoom = GREATER_SPEED_ZOOM_LEVEL
        case BIG_SPEED_RANGE_IN_KMH:
            zoom = BIG_SPEED_ZOOM_LEVEL
        default:
            zoom = HUGE_SPEED_ZOOM_LEVEL
        }
        guard mapView.zoom() != zoom else { return }
        let cameraPostion = TTCameraPositionBuilder.create(withCameraPosition: mapView.cameraPosition().cameraPosition).withZoom(zoom).withAnimationDuration(Int32(ZOOM_CHANGE_ANIMATION_MILLIS)).build()
        mapView.setCameraPosition(cameraPostion)
    }

}

extension ZoomingTheRouteViewController: LocationManagerMockDelegate {
    func didUpdateLocation(_ location: CLLocation) {
        applyLocation(location)
    }
}
