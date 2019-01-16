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
import TomTomOnlineSDKSearch
import TomTomOnlineSDKMaps

class SearchEntryPointsViewController: MapBaseViewController, TTSearchDelegate {
    
    let search = TTSearch()
    
    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Airport", "Shopping Mall"], selectedID: -1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        search.delegate = self
    }
    
    //MARK: OptionsViewDelegate
    
    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        progress.show()
        mapView.annotationManager.removeAllAnnotations()
        switch ID {
        case 1:
            displayEntryPointsForShoppingMall()
        default:
            displayEntryPointsForAirport()
        }
    }
    
    //MARK: Examples
    
    func displayEntryPointsForAirport() {
        let query = TTSearchQueryBuilder.create(withTerm: "Amsterdam Airport Schiphol")
            .build()
        search.search(with: query)
    }
    
    func displayEntryPointsForShoppingMall() {
        let query = TTSearchQueryBuilder.create(withTerm: "Kalvertoren Singel 451").withIdxSet(TTSearchIndex.pointOfInterest)
            .build()
        search.search(with: query)
    }
    
    //MARK: TTSearchDelegate
    
    func search(_ search: TTSearch, completedWith response: TTSearchResponse) {
        progress.hide()
        guard let result = response.results.first else {
            return
        }
        guard let entryPoints = result.entryPoints else {
            return
        }

        let annotation = TTAnnotation(coordinate: result.position)
        mapView.annotationManager.add(annotation)
        for entryPoint in entryPoints {
            let annotation = TTAnnotation(coordinate: entryPoint.position,
                                          annotationImage: TTAnnotationImage.createPNG(withName: "entry_point")!,
                                          anchor: .bottom,
                                          type: .focal)
            mapView.annotationManager.add(annotation)
        }
        mapView.zoomToAllAnnotations()
    }
    
    func search(_ search: TTSearch, failedWithError error: TTResponseError) {
        handleError(error)
    }

}
