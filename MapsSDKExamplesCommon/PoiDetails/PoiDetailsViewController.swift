//
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

@objc public protocol ReviewModelProtocol {
    var reviewText: String { get }
    var reviewDateString: String { get }
}

@objc public protocol PoiDetailsModelProtocol {
    var photos: [UIImage] { get }
    var poiName: String { get }
    var address: String { get }
    var rating: Double { get }
    var maxRating: Double { get }
    var pricing: Double { get }
    var maxPricing: Double { get }
    var category: String { get }
    var socialMediaLinks: [String] { get }
    var reviews: [ReviewModelProtocol] { get }
}

class ReviewView: UIView {
    let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    let reviewTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.font = .italicSystemFont(ofSize: 13)
        label.numberOfLines = 3
        return label
    }()

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(dateLabel)
        addSubview(reviewTextLabel)

        dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true

        reviewTextLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 2).isActive = true
        reviewTextLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        reviewTextLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        reviewTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
    }

    func load(_ review: ReviewModelProtocol) {
        dateLabel.text = review.reviewDateString
        reviewTextLabel.text = review.reviewText
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ReviewsView: UIView {
    let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fillEqually
        view.axis = .vertical
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 15)
        label.text = "Most popular reviews"
        return label
    }()

    func loadReviews(_ reviews: [ReviewModelProtocol]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        reviews.map { (model) -> ReviewView in
            let review = ReviewView()
            review.load(model)
            return review
        }.forEach { stackView.addArrangedSubview($0) }
    }

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc public class PoiDetailsViewController: UIViewController {
    let model: PoiDetailsModelProtocol

    @objc public init(model: PoiDetailsModelProtocol) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static let photoContainerHeightRatio: CGFloat = 2.8
    static let poiInfoContainerHeightRatio: CGFloat = 6

    let contentScrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let photosContainer: ImageScroller = {
        let view = ImageScroller()
        return view
    }()

    let poiInfoView: PoiInfoView = {
        let view = PoiInfoView()
        return view
    }()

    let socialMediaView: SocialMediaView = {
        let view = SocialMediaView()
        return view
    }()

    let reviewsView: ReviewsView = {
        let view = ReviewsView()
        return view
    }()

    let separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()

    let poweredByFoursquareLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .lightGray
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 2
        label.textAlignment = .center
        let text = NSMutableAttributedString(string: "Powered by: ",
                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        let providerText = NSAttributedString(string: "Foursquare",
                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)])
        text.append(providerText)
        label.attributedText = text
        return label
    }()

    fileprivate func setupPhotosContainer() {
        contentScrollView.addSubview(photosContainer)
        photosContainer.backgroundColor = .orange
        photosContainer.topAnchor.constraint(equalTo: contentScrollView.topAnchor).isActive = true
        photosContainer.leftAnchor.constraint(equalTo: contentScrollView.leftAnchor).isActive = true
        photosContainer.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor).isActive = true

        let height = UIScreen.main.bounds.height / PoiDetailsViewController.photoContainerHeightRatio
        photosContainer.heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    fileprivate func setupPoiContainer() {
        contentScrollView.addSubview(poiInfoView)
        poiInfoView.topAnchor.constraint(equalTo: photosContainer.bottomAnchor, constant: 20).isActive = true
        poiInfoView.leftAnchor.constraint(equalTo: contentScrollView.leftAnchor).isActive = true
        poiInfoView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor).isActive = true

        let height = UIScreen.main.bounds.height / PoiDetailsViewController.poiInfoContainerHeightRatio
        poiInfoView.heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    fileprivate func setupSeparatorLabel() {
        contentScrollView.addSubview(separator)
        separator.centerXAnchor.constraint(equalTo: contentScrollView.centerXAnchor).isActive = true
        separator.topAnchor.constraint(equalTo: poiInfoView.bottomAnchor, constant: 15).isActive = true
        separator.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor, multiplier: 0.9).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    fileprivate func setupSocialMedia() {
        contentScrollView.addSubview(socialMediaView)
        socialMediaView.leftAnchor.constraint(equalTo: contentScrollView.leftAnchor).isActive = true
        socialMediaView.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 15).isActive = true
        socialMediaView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor).isActive = true
    }

    fileprivate func setupReviewsViews() {
        contentScrollView.addSubview(reviewsView)
        reviewsView.topAnchor.constraint(equalTo: socialMediaView.bottomAnchor, constant: 15).isActive = true
        reviewsView.leftAnchor.constraint(equalTo: contentScrollView.leftAnchor).isActive = true
        reviewsView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor).isActive = true
        reviewsView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor).isActive = true
    }

    fileprivate func setupScrollView() {
        view.addSubview(contentScrollView)
        contentScrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentScrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        contentScrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        contentScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    fileprivate func setupPoweredBy() {
        view.addSubview(poweredByFoursquareLabel)
        poweredByFoursquareLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        poweredByFoursquareLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        poweredByFoursquareLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        poweredByFoursquareLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    override public func loadView() {
        super.loadView()
        view.backgroundColor = .white
        setupScrollView()
        setupPhotosContainer()
        setupPoiContainer()
        setupSeparatorLabel()
        setupSocialMedia()
        setupReviewsViews()
        setupPoweredBy()
        loadModel(model)
    }

    private func loadModel(_ model: PoiDetailsModelProtocol) {
        photosContainer.images = model.photos
        socialMediaView.loadLinks(model.socialMediaLinks)
        reviewsView.loadReviews(model.reviews)
        poiInfoView.load(model)
    }
}
