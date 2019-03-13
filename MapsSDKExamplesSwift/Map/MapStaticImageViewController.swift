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
import TomTomOnlineSDKMapsStaticImage

class MapStaticImageViewController: CollectionBaseViewController {
    
    override func getImageView(for index: Int) -> UIImageView {
        switch index {
        case 5:
            return getAmsterdamNightWithZoomLevel8Image()
        case 4:
            return getAmsterdamWithAzureStyleImage()
        case 3:
            return getAmsterdamWithHybrydImage()
        case 2:
            return getAmsterdamWithZoomLevel15Image()
        case 1:
            return getAmsterdamNightImage()
        default:
            return getAmsterdamCustomImage()
        }
    }

    func getAmsterdamCustomImage() -> UIImageView {
        let query = TTStaticImageQueryBuilder.withCenter(TTCoordinate.AMSTERDAM())
                                             .withLayer(.basic)
                                             .withStyle(.main)
                                             .withExt(.PNG)
                                             .withHeight(512)
                                             .withWidth(512)
                                             .build()
        return performQuery(query)
    }
    
    func getAmsterdamNightImage() -> UIImageView {
        let query = TTStaticImageQueryBuilder.withCenter(TTCoordinate.AMSTERDAM())
                                             .withStyle(.night)
                                             .build()
        return performQuery(query)
    }
    
    func getAmsterdamWithZoomLevel15Image() -> UIImageView {
        let query = TTStaticImageQueryBuilder.withCenter(TTCoordinate.AMSTERDAM())
                                             .withZoomLevel(15)
                                             .build()
        return performQuery(query)
    }
    
    func getAmsterdamWithHybrydImage() -> UIImageView {
        let query = TTStaticImageQueryBuilder.withCenter(TTCoordinate.AMSTERDAM())
                                             .withLayer(.hybrid)
                                             .build()
        return performQuery(query)
    }
    
    func getAmsterdamWithAzureStyleImage() -> UIImageView {
        let query = TTStaticImageQueryBuilder.withCenter(TTCoordinate.AMSTERDAM())
                                             .withCustomStyle("main-azure")
                                             .build()
        return performQuery(query)
    }
    
    func getAmsterdamNightWithZoomLevel8Image() -> UIImageView {
        let query = TTStaticImageQueryBuilder.withCenter(TTCoordinate.AMSTERDAM())
                                             .withStyle(.night)
                                             .withZoomLevel(8)
                                             .build()
        return performQuery(query)
    }
    
    private func performQuery(_ query: TTStaticImageQuery) -> UIImageView {
        let imageView = ProgressImageView(frame: CGRect.zero)
        let staticImage = TTStaticImage()
        staticImage.image(for: query) { (image, response) in
            guard let image = image else {
                return
            }
            imageView.image = image
        }
        return imageView
    }

}
