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
import CoreLocation
import MapsSDKExamplesCommon
import MapsSDKExamplesVC
import TomTomOnlineSDKSearch

class SearchAddressViewController: SearchBaseViewController, TTSearchDelegate {
    
    var location: CLLocation?
    let search = TTSearch()
    
    override func segmentsForControllSelected() -> Int {
        return 0
    }
    
    override func segmentsForControll() -> [String]  {
        return ["GLOBAL", "NEAR ME"]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        search.delegate = self
    }
    
    override func searchBarFinishedEditting(with term: String) {
        progress.show()
        if segmentedControl!.selectedSegmentIndex == 0 {
            searchForTerm(term)
        } else {
            guard let location = self.location else {
                toast.toast(message: "Location not determined")
                segmentedControl!.selectedSegmentIndex = 0
                progress.hide()
                return
            }
            searchForTerm(term, at: location.coordinate)
        }
    }
    
    override func segmentChanged(_ sender: UISegmentedControl) {
        searchBar?.resignFirstResponder()
        if sender.selectedSegmentIndex == 1 {
            location = locationManager.lastLocation
        } else {
            location = nil
        }
        if let term = searchBar!.text {
            searchBarFinishedEditting(with: term)
        }
    }

    //MARK: Examples
    
    func searchForTerm(_ term: String) {
        let query = TTSearchQueryBuilder.create(withTerm: term)
            .build()
        search.search(with: query)
    }
    
    func searchForTerm(_ term: String, at coordinate: CLLocationCoordinate2D) {
        let query = TTSearchQueryBuilder.create(withTerm: term)
            .withPosition(coordinate)
            .build()
        search.search(with: query)
    }

    //MARK: TTSearchDelegate
    
    func search(_ search: TTSearch, completedWith response: TTSearchResponse) {
        progress.hide()
        displayResults(response.results)
    }
    
    func search(_ search: TTSearch, failedWithError error: TTResponseError) {
        toast.toast(message: "error " + (error.userInfo["description"] as! String))
        progress.hide()
    }
    
}
