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
import UIKit

class MapMatchingViewController: MapBaseViewController, TTMapViewDelegate, TTAnnotationDelegate, TTMatcherDelegate {
    var source: DrivingSource?
    private var chevron: TTChevronObject?
    private let locationProvider = LocationCSVProvider(csvFile: "simple_route")
    var startSending = false
    var matcher: TTMatcher!

    lazy var emitter: RouteLocationEmitter = {
        let e = RouteLocationEmitter(routeProvider: locationProvider)
        e.delegate = self
        return e
    }()

    override func setupInitialCameraPosition() {
        mapView.center(on: locationProvider.locations[0].coordinate, withZoom: 18)
    }

    func onMapReady(_ mapView: TTMapView) {
        mapView.annotationManager.delegate = self
        createChevron()
        start()

        if startSending == false {
            self.sendingLocation()
            self.startSending = true
        }
        mapView.maxZoom = TTMapZoom.MAX()
        mapView.minZoom = TTMapZoom.MIN()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        matcher = TTMatcher(matchDataSet: mapView)
        matcher.delegate = self
        setupEtaView()
        etaView.update(text: "Red circle shows raw GPS position", icon: UIImage(named: "info_small")!)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        emitter.stop()
    }

    func createChevron() {
        mapView.isShowsUserLocation = false
        let animation = TTChevronAnimationOptionsBuilder.create(withAnimatedCornerRounding: true).build()
        chevron = TTChevronObject(normalImage: TTChevronObject.defaultNormalImage(), withDimmedImage: TTChevronObject.defaultDimmedImage(), with: animation)
    }

    func start() {
        mapView.trackingManager.add(chevron!)
        source = DrivingSource(trackingManager: mapView.trackingManager, trackingObject: chevron!)
        source?.updateLocation(location: locationProvider.locations[0])
        mapView.trackingManager.setBearingSmoothingFilter(TTTrackingManagerDefault.bearingSmoothFactor())
        mapView.trackingManager.start(chevron!)
        source?.activate()
    }

    func matcher(providerLocation: ProviderLocation) {
        let location = TTMatcherLocation(coordinate: providerLocation.coordinate, withBearing: providerLocation.bearing, withBearingValid: true, withEPE: 0.0, withSpeed: providerLocation.speed, withDuration: providerLocation.timestamp)
        matcher.setMatcherLocation(location)
    }

    public func matcherResultMatchedLocation(_ matched: TTMatcherLocation, withOriginalLocation original: TTMatcherLocation, isMatched: Bool) {
        drawRedCircle(coordinate: original.coordinate)
        source?.updateLocation(location: TTLocation(coordinate: matched.coordinate, withRadius: matched.radius, withBearing: matched.bearing, withAccuracy: 0.0, isDimmed: !isMatched))
        chevron?.isHidden = false
    }

    func sendingLocation() {
        emitter.startEmitting()
    }

    func drawRedCircle(coordinate: CLLocationCoordinate2D) {
        mapView.annotationManager.removeAllOverlays()
        let redCircle = TTCircle(center: coordinate, radius: 2, opacity: 1, width: 10, color: UIColor.red, fill: true, colorOutlet: UIColor.red)
        mapView.annotationManager.add(redCircle)
    }
}

extension MapMatchingViewController: RouteLocationEmitterDelegate {
    func routeLocationEmitter(_: RouteLocationEmitter, didEmitt location: ProviderLocation) {
        matcher(providerLocation: location)
    }
}
