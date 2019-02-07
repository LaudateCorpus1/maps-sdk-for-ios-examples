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

class MapMatchingViewController: MapBaseViewController, TTMapViewDelegate, TTAnnotationDelegate, TTMatcherDelegate {

    var source: DrivingSource?
    private var chevron: TTChevronObject?
    var startSending = false
    var matcher: TTMatcher?

    func onMapReady(_ mapView: TTMapView) {
        mapView.annotationManager.delegate = self
        createChevron()
        start()

        if startSending == false {
            OperationQueue().addOperation {
                self.sendingLocation()
                self.startSending = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        matcher = TTMatcher(matchDataSet: mapView)
        matcher?.delegate = self
    }

    func createChevron() {
        mapView.isShowsUserLocation = false
        chevron = TTChevronObject(normalImage:TTChevronObject.defaultNormalImage(), withNormalImageName: "active", withDimmedImage: TTChevronObject.defaultDimmedImage(), withDimmedImageName: "inactive")
    }

    func start() {
        let camera = TTCameraPosition(camerPosition: TTCoordinate.LODZ_SREBRZYNSKA_START(),
                                      withAnimationDuration: TTCamera.ANIMATION_TIME(),
                                      withBearing: TTCamera.BEARING_START(),
                                      withPitch: TTCamera.DEFAULT_MAP_PITCH_FLAT(),
                                      withZoom: 18)
        mapView.setCameraPosition(camera)
        mapView.trackingManager.add(self.chevron!)
        source = DrivingSource(trackingManager: mapView.trackingManager, trackingObject: chevron!)
        mapView.trackingManager.start(chevron!)
        self.source?.activate()
    }

    func matcher(providerLocation: ProviderLocation) {
        let location = TTMatcherLocation(coordinate: providerLocation.coordinate, withBearing: providerLocation.bearing, withBearingValid: true, withEPE: 0.0, withSpeed: providerLocation.speed, withDuration: providerLocation.timestamp)
        matcher?.setMatcherLocation(location)
    }

    public func matcherResultMatchedLocation(_ matched: TTMatcherLocation!, withOriginalLocation original: TTMatcherLocation!, isMatched: Bool) {
        drawRedCircle(coordinate: original.coordinate)
        source?.updateLocation(location:TTLocation(coordinate: matched.coordinate, withRadius: matched.radius, withBearing: matched.bearing, withAccuracy: 0.0, isDimmed: !isMatched))
     }

    func sendingLocation() {

        let locationProvider = LocationCSVProvider(csvFile: "simple_route")
        for index in 1...locationProvider.locations!.count {

            guard let prev = locationProvider.locations?[index - 1] else { return }
            let next = locationProvider.locations![index]

            let providerLocation = ProviderLocation(coordinate: next.coordinate, withRadius: next.radius, withBearing: next.bearing, withAccuracy: next.accuracy)
            providerLocation.timestamp = next.timestamp
            providerLocation.speed = next.speed

            self.matcher(providerLocation: providerLocation)

            let time = next.timestamp - prev.timestamp
            sleep(UInt32(time/1000))
        }
    }

    func drawRedCircle(coordinate: CLLocationCoordinate2D) {
        OperationQueue.main.addOperation {
            self.mapView.annotationManager.removeAllOverlays();
            let redCircle = TTCircle(center: coordinate, radius: 2, opacity: 1, width: 10, color: UIColor.red, fill: true, colorOutlet: UIColor.red)
            self.mapView.annotationManager.add(redCircle)
        }
    }
}
