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

class SearchTypeaheadParameterViewController: SearchBaseViewController, TTSearchDelegate {
    let search = TTSearch(key: Key.Search)

    override func shouldDisplaySegmentedControll() -> Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        search.delegate = self
    }

    override func searchBarIsEditting(with term: String) {
        searchForTermWithTypeahead(term)
    }

    // MARK: Examples

    func searchForTermWithTypeahead(_ term: String) {
        let query = TTSearchQueryBuilder.create(withTerm: term)
            .withTypeAhead(true)
            .build()
        search.search(with: query)
    }

    // MARK: TTSearchDelegate

    func search(_: TTSearch, completedWith response: TTSearchResponse) {
        displayResults(response.results)
    }

    func search(_: TTSearch, failedWithError error: TTResponseError) {
        handleError(error)
    }

    func cancelSearch() {
        self.search.cancel()
    }

}
