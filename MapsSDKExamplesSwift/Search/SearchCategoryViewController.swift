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

class SearchCategoryViewController: SearchBaseViewController, TTSearchDelegate {
    
    let search = TTSearch()
    
    override func shouldDisplaySearchBar() -> Bool {
        return false
    }
    
    override func segmentsForControllSelected() -> Int {
        return -1
    }
    
    override func segmentsForControll() -> [String]  {
        return ["PARKING", "GAS", "ATM"]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        search.delegate = self
    }
    
    override func segmentChanged(_ sender: UISegmentedControl) {
        guard locationManager.lastLocation != nil else {
            toast.toast(message: "Location not determined")
            segmentedControl!.selectedSegmentIndex = -1
            return
        }
        progress.show()
        switch sender.selectedSegmentIndex {
        case 2:
            searchCategoryATM()
        case 1:
            searchCategoryGas()
        default:
            searchCategoryParking()
        }
    }
    
    //MARK: Examples
    
    func searchCategoryParking() {
        let query = TTSearchQueryBuilder.create(withTerm: "parking")
            .withCategory(true)
            .withPosition(locationManager.lastLocation!.coordinate)
            .build()
        search.search(with: query)
    }
    
    func searchCategoryGas() {
        let query = TTSearchQueryBuilder.create(withTerm: "gas")
            .withCategory(true)
            .withPosition(locationManager.lastLocation!.coordinate)
            .build()
        search.search(with: query)
    }
    
    func searchCategoryATM() {
        let query = TTSearchQueryBuilder.create(withTerm: "atm")
            .withCategory(true)
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
