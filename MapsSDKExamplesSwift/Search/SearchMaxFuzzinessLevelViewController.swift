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

import UIKit
import MapsSDKExamplesCommon
import MapsSDKExamplesVC
import TomTomOnlineSDKSearch

class SearchMaxFuzzinessLevelViewController: SearchBaseViewController, TTSearchDelegate {
    
    let search = TTSearch()
    
    override func segmentsForControllSelected() -> Int {
        return 0
    }
    
    override func segmentsForControll() -> [String]  {
        return ["Max 1", "Max 2", "Max 3"]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        search.delegate = self
    }
    
    override func segmentChanged(_ sender: UISegmentedControl) {
        guard locationManager.lastLocation != nil else {
            toast.toast(message: "Location not determined")
            segmentedControl!.selectedSegmentIndex = 0
            return
        }
        searchBar?.resignFirstResponder()
        if let term = searchBar!.text {
            progress.show()
            searchForTerm(term, maxFuzzyLevel: UInt(sender.selectedSegmentIndex + 1))
        }
    }
    
    override func searchBarFinishedEditting(with term: String) {
        guard locationManager.lastLocation != nil else {
            toast.toast(message: "Location not determined")
            segmentedControl!.selectedSegmentIndex = 0
            return
        }
        progress.show()
        searchForTerm(term, maxFuzzyLevel: UInt(segmentedControl!.selectedSegmentIndex + 1))
    }
    
    //MARK: Examples
    
    func searchForTerm(_ term: String, maxFuzzyLevel: UInt) {
        let query = TTSearchQueryBuilder.create(withTerm: term)
            .withMinFuzzyLevel(1)
            .withMaxFuzzyLevel(maxFuzzyLevel)
            .withPosition(locationManager.lastLocation!.coordinate)
            .build()
        search.search(with: query)
    }
    
    //MARK: TTSearchDelegate
    
    func search(_ search: TTSearch, completedWith response: TTSearchResponse) {
        progress.hide()
        displayResults(response.results)
    }
    
    func search(_ search: TTSearch, failedWithError error: TTResponseError) {
        handleError(error)
    }
    
}

