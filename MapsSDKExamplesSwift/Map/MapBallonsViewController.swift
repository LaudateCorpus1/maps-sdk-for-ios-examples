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

class MapBallonsViewController: MapBaseViewController, TTAnnotationDelegate {
    
    var customAnnotation: TTAnnotation?
    
    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Simple", "Custom"], selectedID: -1)
    }
    
    override func setupMap() {
        super.setupMap()
        mapView.annotationManager.delegate = self
    }
    
    //MARK: OptionsViewDelegate
    
    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        switch ID {
        case 1:
            displayCustomBallon()
        default:
            displaySimpleBallon()
        }
    }
    
    //MARK: TTAnnotationDelegate
    
    func annotationManager(_ manager: TTAnnotationManager, viewForSelectedAnnotation selectedAnnotation: TTAnnotation) -> UIView & TTCalloutView {
        if let customAnnotation = self.customAnnotation, customAnnotation == selectedAnnotation {
            return CustomCallout(frame: CGRect.zero)
        } else {
            return TTCalloutOutlineView(text: "\(selectedAnnotation.coordinate.latitude),\(selectedAnnotation.coordinate.longitude)")
        }
    }
    
    func annotationManager(_ manager: TTAnnotationManager, annotationSelected annotation: TTAnnotation) {
        //handle annotation selected event
    }
    
    //MARK: Examples
    
    func displaySimpleBallon() {
        let annotation = TTAnnotation(coordinate: TTCoordinate.AMSTERDAM())
        mapView.annotationManager.add(annotation)
        mapView.annotationManager.select(annotation)
    }
    
    func displayCustomBallon() {
        let annotation = TTAnnotation(coordinate: TTCoordinate.AMSTERDAM())
        customAnnotation = annotation
        mapView.annotationManager.add(annotation)
        mapView.annotationManager.select(annotation)
    }

}
