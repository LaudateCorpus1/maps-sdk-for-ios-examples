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
import TomTomOnlineSDKMapsDriving
import TomTomOnlineSDKRouting
import UIKit

class RouteMatchingViewController: RoutingBaseViewController, TTMapViewDelegate, TTAnnotationDelegate, TTMatcherDelegate, TTRouteResponseDelegate {
    let routePlanner = TTRoute(key: Key.Routing)
    var waypoints = [TTCoordinate.LODZ_SREBRZYNSKA_WAYPOINT_A(),
                     TTCoordinate.LODZ_SREBRZYNSKA_WAYPOINT_B(),
                     TTCoordinate.LODZ_SREBRZYNSKA_WAYPOINT_C()]
    var route: TTMapRoute?
    var source: DrivingSource?
    var chevron: TTChevronObject?
    var matcher: TTMatcher?
    var timer: Timer?
    var startSending = false

    override func setupInitialCameraPosition() {
        mapView.center(on: TTCoordinate.LODZ_SREBRZYNSKA_START(), withZoom: 18)
    }

    func onMapReady(_ mapView: TTMapView) {
        mapView.annotationManager.delegate = self
        createChevron()
        createRoute()
        mapView.maxZoom = TTMapZoom.MAX()
        mapView.minZoom = TTMapZoom.MIN()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        routePlanner.delegate = self
        setupEtaView()
        etaView.update(text: "Red circle shows raw GPS position", icon: UIImage(named: "info_small")!)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

    func createChevron() {
        mapView.isShowsUserLocation = false
        let animation = TTChevronAnimationOptionsBuilder.create(withAnimatedCornerRounding: true).build()
        chevron = TTChevronObject(normalImage: TTChevronObject.defaultNormalImage(), withDimmedImage: TTChevronObject.defaultDimmedImage(), with: animation)
    }

    func createRoute() {
        progress.show()
        let query = TTRouteQueryBuilder.create(withDest: TTCoordinate.LODZ_SREBRZYNSKA_STOP(), andOrig: TTCoordinate.LODZ_SREBRZYNSKA_START())
            .withWayPoints(&waypoints, count: UInt(waypoints.count))
            .build()
        routePlanner.plan(with: query)
    }

    func start() {
        mapView.trackingManager.add(chevron!)
        source = DrivingSource(trackingManager: mapView.trackingManager, trackingObject: chevron!)
        source?.updateLocation(location: TTLocation(coordinate: TTCoordinate.LODZ_SREBRZYNSKA_START()))
        mapView.trackingManager.setBearingSmoothingFilter(TTTrackingManagerDefault.bearingSmoothFactor())
        mapView.trackingManager.start(chevron!)
        source?.activate()
    }

    func matching(providerLocation: ProviderLocation) {
        let location = TTMatcherLocation(coordinate: providerLocation.coordinate, withBearing: providerLocation.bearing, withBearingValid: true, withEPE: 0.0, withSpeed: providerLocation.speed, withDuration: providerLocation.timestamp)
        matcher?.setMatcherLocation(location)
    }

    public func matcherResultMatchedLocation(_ matched: TTMatcherLocation, withOriginalLocation original: TTMatcherLocation, isMatched _: Bool) {
        drawRedCircle(coordinate: original.coordinate)
        source?.updateLocation(location: matched)
        chevron?.isHidden = false
    }

    func drawRedCircle(coordinate: CLLocationCoordinate2D) {
        mapView.annotationManager.removeAllOverlays()
        let redCircle = TTCircle(center: coordinate, radius: 2, opacity: 1, width: 10, color: UIColor.red, fill: true, colorOutlet: UIColor.red)
        mapView.annotationManager.add(redCircle)
    }

    private func sendingLocation(mapRoute: TTFullRoute) {
        var index = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            index = index + 1
            if index == mapRoute.coordinatesData().count {
                index = 0
            }

            if index - 1 < 0 {
                return
            }

            let prevCoordinate = LocationUtils.coordinateForValue(value: mapRoute.coordinatesData()[index - 1])
            var origCoordinate = LocationUtils.coordinateForValue(value: mapRoute.coordinatesData()[index])
            let bearing = LocationUtils.bearingWithCoordinate(coordinate: origCoordinate, prevCoordianate: prevCoordinate)
            origCoordinate = RandomizeCoordinate.interpolate(coordinate: origCoordinate)
            let randomCoordinate = TTLocation(coordinate: origCoordinate, withRadius: 0.0, withBearing: 0.0, withAccuracy: 0.0, isDimmed: true)
            let providerLocation = ProviderLocation(coordinate: randomCoordinate.coordinate, withRadius: 0.0, withBearing: bearing, withAccuracy: 0.0)
            providerLocation.timestamp = Date().timeIntervalSince1970
            providerLocation.speed = 5.0
            self.matching(providerLocation: providerLocation)
        })
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
        progress.hide()
        matcher = TTMatcher(matchDataSet: plannedRoute)
        matcher?.delegate = self
        start()
        sendingLocation(mapRoute: plannedRoute)
    }

    func route(_: TTRoute, completedWith responseError: TTResponseError) {
        handleError(responseError)
    }
}
