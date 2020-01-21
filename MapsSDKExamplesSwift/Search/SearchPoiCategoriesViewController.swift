//  Copyright (c) 2020 TomTom N.V. All rights reserved.
//
//  This software is the proprietary copyright of TomTom N.V. and its subsidiaries and may be used
//  for internal evaluation purposes or commercial use strictly subject to separate licensee
//  agreement between you and TomTom. If you are the licensee, you are only permitted to use
//  this Software in accordance with the terms of your license agreement. If you are not the
//  licensee then you are not authorised to use this software in any manner and should
//  immediately return it to TomTom N.V.

import MapsSDKExamplesVC
import TomTomOnlineSDKSearch

class SearchPoiCategoriesViewController: TableBaseViewController {
    private let poiCategoriesService = TTPoiCategories()
    private var categories: [TTPoiCategory] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        progress.show()
        poiCategoriesService.delegate = self
        let query = TTPoiCategoriesQueryBuilder.create().build()
        poiCategoriesService.request(with: query)
    }
}

extension SearchPoiCategoriesViewController: TTPoiCategoriesDelegate {
    func poiCategories(_: TTPoiCategories, completedWith response: TTPoiCategoriesResponse) {
        categories = response.results
        displayResults(categories)
        progress.hide()
    }

    func poiCategories(_: TTPoiCategories, failedWithError error: TTResponseError) {
        handleError(error)
    }
}

extension SearchPoiCategoriesViewController {
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let category: TTPoiCategory = results[indexPath.row] as? TTPoiCategory else {
            return
        }
        if category.children.isEmpty {
            return
        }
        let parent = self.navigationController
        let table = TableBaseViewController()
        table.results = category.children
        table.name = category.name
        parent?.pushViewController(table, animated: true)
    }
}
