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

import Foundation

import UIKit
import MapsSDKExamplesCommon
import MapsSDKExamplesVC
import TomTomOnlineSDKMaps
import TomTomOnlineSDKGeofencing

class FenceAnnotation: TTAnnotation {
    var title: String?
}

class GeofencingReportViewController: GeofencingBaseViewController, TTAnnotationDelegate {

    var service: TTGeofencingReportService?
    let projectId1 = "57287023-a968-492c-8473-7e049a606425"
    let projectId2 = "fcf6d609-550d-49ff-bcdf-02bba08baa28"
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
        service = TTGeofencingReportService()
        mapView.annotationManager.delegate = self
        etaView.update(text: "Drag a pin inside/outside of a fence", icon: UIImage(named: "info_small")!)
    }

    //MARK: OptionsViewDelegate
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

    //MARK: Examples
    func requestGeofencingReport(coordinate: CLLocationCoordinate2D, projectId: String) {
        let reportQuery = TTGeofencingReportQueryBuilder(location: TTLocation(coordinate: coordinate))
            .withProject(projectId)
            .withRange(range).build()

        service?.report(with: reportQuery) { (report, error) in
            self.responseGeofencing(report: report)
        }
    }

    func responseGeofencing(report: TTGeofencingReport?) {
        self.removeAnnotationFances()
        report?.inside.forEach({ (reportFenceDetails) in
            self.addMarker(coordinate: reportFenceDetails.closestPoint.coordinate, title: reportFenceDetails.entity.name)
            self.inside.append(reportFenceDetails.entity.name)
        })

        report?.outside.forEach({ (reportFenceDetails) in
            self.addMarker(coordinate: reportFenceDetails.closestPoint.coordinate, title: reportFenceDetails.entity.name)
            self.outside.append(reportFenceDetails.entity.name)
        })

        self.mapView.annotationManager.select(self.draggableAnnotation)
    }

    override func setupCenterOnWillHappen() {
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
        if state == .viewDragStateIdle && annotation == draggableAnnotation {
            self.requestGeofencingReport(coordinate: annotation.coordinate, projectId: projectIdActive)
        }
    }

    func annotationManager(_ manager: TTAnnotationManager, viewForSelectedAnnotation selectedAnnotation: TTAnnotation) -> UIView & TTCalloutView {
        if ((selectedAnnotation as? FenceAnnotation) != nil) {
            let title = (selectedAnnotation as! FenceAnnotation).title!
            return TTCalloutOutlineView(uiView: label(forText: " This is the closest location to \n \"\(title)\" border"))
        }
        return TTCalloutOutlineView(uiView: label(forText: createDescriptionWith(inside: inside, withOutside: outside)))
    }

    func removeAnnotationFances() {
        var annotationsToRemove =  Set(mapView.annotationManager.annotations)
        annotationsToRemove.remove(draggableAnnotation)
        mapView.annotationManager.remove(Array(annotationsToRemove))
        inside.removeAll()
        outside.removeAll()
    }
}

