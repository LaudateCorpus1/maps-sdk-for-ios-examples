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
import TomTomOnlineSDKMapsDriving
import TomTomOnlineSDKRouting

class RouteMatchingViewController: MapBaseViewController, TTMapViewDelegate, TTAnnotationDelegate, TTMatcherDelegate {

    let routePlanner = TTRoute()
    var waypoints = [TTCoordinate.LODZ_SREBRZYNSKA_WAYPOINT_A(),
                     TTCoordinate.LODZ_SREBRZYNSKA_WAYPOINT_B(),
                     TTCoordinate.LODZ_SREBRZYNSKA_WAYPOINT_C()]
    var route:TTMapRoute?
    var source: DrivingSource?
    var chevron: TTChevronObject?
    var matcher: TTMatcher?
    var timer: Timer?
    var startSending = false

    func onMapReady(_ mapView: TTMapView) {
        mapView.annotationManager.delegate = self
        createChevron()
        createRoute()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

    func createChevron() {
        mapView.isShowsUserLocation = false
        chevron = TTChevronObject(normalImage:TTChevronObject.defaultNormalImage(), withNormalImageName: "active", withDimmedImage: TTChevronObject.defaultDimmedImage(), withDimmedImageName: "inactive");
    }

    func start() {
        mapView.trackingManager.add(chevron!)
        mapView.trackingManager.start(chevron!)
        source = DrivingSource(trackingManager: mapView.trackingManager, trackingObject: chevron!);
        source?.activate()

        let camera = TTCameraPosition(camerPosition: TTCoordinate.LODZ_SREBRZYNSKA_START(),
                                      withAnimationDuration: TTCamera.ANIMATION_TIME(),
                                      withBearing: TTCamera.BEARING_START(),
                                      withPitch: TTCamera.DEFAULT_MAP_PITCH_FLAT(),
                                      withZoom: 17)
        mapView.setCameraPosition(camera)
    }

    func matching(providerLocation: ProviderLocation) {
        let location = TTMatcherLocation(coordinate: providerLocation.coordinate, withBearing: providerLocation.bearing, withBearingValid: true, withEPE: 0.0, withSpeed: providerLocation.speed, withDuration: providerLocation.timestamp)
        matcher?.setMatcherLocation(location)
    }

    public func matcherResultMatchedLocation(_ matched: TTMatcherLocation!, withOriginalLocation original: TTMatcherLocation!, isMatched: Bool) {
        drawRedCircle(coordinate: original.coordinate)
        source?.updateLocation(location: matched)
     }

    func drawRedCircle(coordinate: CLLocationCoordinate2D) {
        OperationQueue.main.addOperation {
            self.mapView.annotationManager.removeAllOverlays();
            let redCircle = TTCircle(center: coordinate, radius: 2, opacity: 1, width: 10, color: UIColor.red, fill: true, colorOutlet: UIColor.red)
            self.mapView.annotationManager.add(redCircle)
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
                self.matcher = TTMatcher(matchDataSet: plannedRoute)
                self.matcher?.delegate = self
                self.start()
                self.sendingLocation(mapRoute: plannedRoute!)

            }
        }
    }

    func displayPlannedRoute(plannedRoute: TTFullRoute) {
        self.route = TTMapRoute(coordinatesData: plannedRoute)
        OperationQueue.main.addOperation({
            self.mapView.routeManager.add(self.route!)
            self.mapView.routeManager.update(self.route!, style: TTMapRouteStyle.defaultActive())
            self.mapView.routeManager.bring(toFrontRoute: self.route!)
        })
    }

    public func sendingLocation(mapRoute: TTFullRoute) {

        var index = 0;
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in

            index = index + 1;
            if index == mapRoute.coordinatesData().count {
                index = 0;
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
}
