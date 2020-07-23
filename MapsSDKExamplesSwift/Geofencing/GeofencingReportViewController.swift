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

import Foundation

import MapsSDKExamplesCommon
import MapsSDKExamplesVC
import TomTomOnlineSDKGeofencing
import TomTomOnlineSDKMaps
import UIKit

class FenceAnnotation: TTAnnotation {
    var title: String?
}

class GeofencingReportViewController: GeofencingBaseViewController, TTAnnotationDelegate {
    /**
     * This project ID's are related to the API key that you are using.
     * To make this example working, you must create a proper structure for your API Key by running
     * TomTomGeofencingProjectGenerator.sh script which is located in the sampleapp/scripts folder.
     * Script takes an API Key and Admin Key that you generated from
     * https://developer.tomtom.com/geofencing-api-public-preview/geofencing-documentation-configuration-service/register-admin-key
     *
     * and creates two projects with fences like in this example. Use project ID's returned by the
     * script and update this two fields.
     */

    var service: TTGeofencingReportService?
    let projectId1 = "b7bc0eef-0e34-4dcf-90e0-3987aa2c7748"
    let projectId2 = "e5ee4262-b29a-46ff-a4a4-112dd27b01bd"
    var projectIdActive = ""
    var draggableAnnotation: TTAnnotation!
    var inside: [String] = []
    var outside: [String] = []
    let range = 5000.0

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["One fence", "Two fences"], selectedID: -1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        service = TTGeofencingReportService(key: Key.Geofencing)
        mapView.annotationManager.delegate = self
        etaView.update(text: "Drag a pin inside/outside of a fence", icon: UIImage(named: "info_small")!)
    }

    // MARK: OptionsViewDelegate

    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        mapView.annotationManager.removeAllOverlays()
        mapView.annotationManager.removeAllAnnotations()
        draggableAnnotationPin()
        switch ID {
        case 1:
            drawAmsterdamCircle(TTCoordinate.AMSTERDAM_CIRCLE_CENTER(), withRadius: TTLocationDistance.AMSTERDAM_CIRCLE_CENTER_RADIUS())
            drawAmsterdamPolygon()
            projectIdActive = projectId2
        default:
            drawAmsterdamPolygon()
            projectIdActive = projectId1
        }
        requestGeofencingReport(coordinate: draggableAnnotation.coordinate, projectId: projectIdActive)
    }

    // MARK: Examples

    func requestGeofencingReport(coordinate: CLLocationCoordinate2D, projectId: String) {
        let reportQuery = TTGeofencingReportQueryBuilder(location: TTLocation(coordinate: coordinate))
            .withProject(projectId)
            .withRange(range).build()

        service?.report(with: reportQuery) { report, _ in
            self.responseGeofencing(report: report)
        }
    }

    func responseGeofencing(report: TTGeofencingReport?) {
        self.removeAnnotationFances()
        report?.inside.forEach { reportFenceDetails in
            self.addMarker(coordinate: reportFenceDetails.closestPoint.coordinate, title: reportFenceDetails.entity.name)
            self.inside.append(reportFenceDetails.entity.name)
        }

        report?.outside.forEach { reportFenceDetails in
            self.addMarker(coordinate: reportFenceDetails.closestPoint.coordinate, title: reportFenceDetails.entity.name)
            self.outside.append(reportFenceDetails.entity.name)
        }

        self.mapView.annotationManager.select(self.draggableAnnotation)
    }

    override func setupInitialCameraPosition() {
        mapView.center(on: TTCoordinate.AMSTERDAM_CIRCLE_CENTER(), withZoom: 12)
    }

    func addMarker(coordinate: CLLocationCoordinate2D, title: String) {
        let annotation = FenceAnnotation(coordinate: coordinate,
                                         annotationImage: TTAnnotationImage.createPNG(withName: "entry_point")!,
                                         anchor: .bottom,
                                         type: .focal)
        annotation.title = title
        mapView.annotationManager.add(annotation)
    }

    func draggableAnnotationPin() {
        draggableAnnotation = TTAnnotation(coordinate: TTCoordinate.AMSTERDAM())
        draggableAnnotation.isDraggable = true
        mapView.annotationManager.add(draggableAnnotation)
    }

    func annotationManager(_ manager: TTAnnotationManager, dragging annotation: TTAnnotation, stateDrag state: TTAnnotationDragState) {
        manager.deselectAnnotation()
        if state == .viewDragStateIdle, annotation == draggableAnnotation {
            self.requestGeofencingReport(coordinate: annotation.coordinate, projectId: projectIdActive)
        }
    }

    func annotationManager(_: TTAnnotationManager, viewForSelectedAnnotation selectedAnnotation: TTAnnotation) -> UIView & TTCalloutView {
        if (selectedAnnotation as? FenceAnnotation) != nil {
            let title = (selectedAnnotation as! FenceAnnotation).title!
            return TTCalloutOutlineView(uiView: label(forText: " This is the closest location to \n \"\(title)\" border"))
        }
        return TTCalloutOutlineView(uiView: label(forText: createDescriptionWith(inside: inside, withOutside: outside)))
    }

    func removeAnnotationFances() {
        var annotationsToRemove = Set(mapView.annotationManager.annotations)
        annotationsToRemove.remove(draggableAnnotation)
        mapView.annotationManager.remove(Array(annotationsToRemove))
        inside.removeAll()
        outside.removeAll()
    }
}
