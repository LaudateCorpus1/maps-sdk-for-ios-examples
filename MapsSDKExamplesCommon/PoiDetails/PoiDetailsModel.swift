/**
 * Copyright (c) 2020 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its subsidiaries and may be used
 * for internal evaluation purposes or commercial use strictly subject to separate licensee
 * agreement between you and TomTom. If you are the licensee, you are only permitted to use
 * this Software in accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and should
 * immediately return it to TomTom N.V.
 */

import TomTomOnlineSDKSearch
import UIKit

@objc public class PoiDetailsModel: NSObject, PoiDetailsModelProtocol {
    public var photos: [UIImage]
    public var poiName: String
    public var address: String
    public var rating: Double
    public var maxRating: Double
    public var pricing: Double
    public var maxPricing: Double
    public var category: String
    public var socialMediaLinks: [String]
    public var reviews: [ReviewModelProtocol]

    @objc public init?(photos: [UIImage], annotationData: SearchResultAnnotation, poiDetails: PoiDetails) {
        guard let poiName = annotationData.result.poi?.name,
              let adress = annotationData.result.address.freeformAddress,
              let ratingValue = poiDetails.rating?.value,
              let maxRating = poiDetails.rating?.maxValue,
              let pricing = poiDetails.priceRange?.value,
              let maxPricing = poiDetails.priceRange?.maxValue,
              let category = annotationData.result.poi?.categories.first else { return nil }

        let socialMediaArray = poiDetails.socialMedia.map { $0.url }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.reviews = poiDetails.reviews.map { DetailsReview(reviewText: $0.text, reviewDateString: df.string(from: $0.date)) }
        self.photos = photos
        self.poiName = poiName
        self.address = adress
        self.rating = Double(ratingValue)
        self.maxRating = maxRating
        self.pricing = pricing
        self.maxPricing = maxPricing
        self.category = "Category: \(category)"
        self.socialMediaLinks = socialMediaArray
    }
}

public class DetailsReview: ReviewModelProtocol {
    public var reviewText: String
    public var reviewDateString: String

    init(reviewText: String, reviewDateString: String) {
        self.reviewText = reviewText
        self.reviewDateString = reviewDateString
    }
}

@objc public class AnnotationPoiDetailsSpecification: NSObject, PoiDetailsSpecification {
    public var poiDetailsID: String

    @objc public init(poiDetailsID: String) {
        self.poiDetailsID = poiDetailsID
    }
}

@objc public class PoiPhoto: NSObject, PoiPhotoSpecificationProtocol, PoiPhotoSize {
    public var width: Int
    public var height: Int
    public var photoID: String
    public var photoSize: PoiPhotoSize?

    @objc public init(photoID: String) {
        self.photoID = photoID
        self.width = 800
        self.height = 600
        super.init()
        self.photoSize = self
    }
}
