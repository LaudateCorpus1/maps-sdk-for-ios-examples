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
import TomTomOnlineSDKSearch
import UIKit

class SearchLanguageSelectorViewController: SearchBaseViewController, TTSearchDelegate {
    let search = TTSearch(key: Key.Search)

    override func segmentsForControllSelected() -> Int {
        return 0
    }

    override func segmentsForControll() -> [String] {
        return ["🇬🇧 EN", "🇩🇪 DE", "🇪🇸 ES", "🇫🇷 FR"]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        search.delegate = self
    }

    override func segmentChanged(_: UISegmentedControl) {
        searchBar?.resignFirstResponder()
        if let term = searchBar!.text {
            progress.show()
            searchForTerm(term, with: languageForIndex(index: segmentedControl!.selectedSegmentIndex))
        }
    }

    override func searchBarFinishedEditting(with term: String) {
        progress.show()
        searchForTerm(term, with: languageForIndex(index: segmentedControl!.selectedSegmentIndex))
    }

    func languageForIndex(index: Int) -> String {
        switch index {
        case 3:
            return "fr-FR"
        case 2:
            return "es-ES"
        case 1:
            return "de-DE"
        default:
            return "en-GB"
        }
    }

    // MARK: Example

    func searchForTerm(_ term: String, with language: String) {
        let query = TTSearchQueryBuilder.create(withTerm: term)
            .withLang(language)
            .build()
        search.search(with: query)
    }

    // MARK: TTSearchDelegate

    func search(_: TTSearch, completedWith response: TTSearchResponse) {
        progress.hide()
        displayResults(response.results)
    }

    func search(_: TTSearch, failedWithError error: TTResponseError) {
        handleError(error)
    }
}
