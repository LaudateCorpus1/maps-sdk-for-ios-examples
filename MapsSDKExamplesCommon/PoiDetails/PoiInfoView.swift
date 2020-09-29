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

class PoiInfoView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 24)
        label.numberOfLines = 2
        return label
    }()

    let categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    let addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 15)
        label.numberOfLines = 2
        return label
    }()

    let ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    let pricingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        return label
    }()

    fileprivate func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 30).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }

    fileprivate func setupCategoryLabel() {
        addSubview(categoryLabel)
        categoryLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        categoryLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 30).isActive = true
        categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
    }

    fileprivate func setupAddressLabel() {
        addSubview(addressLabel)
        addressLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        addressLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        addressLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 10).isActive = true
    }

    fileprivate func setupRatingLabel() {
        addSubview(ratingLabel)
        ratingLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        ratingLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        ratingLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 10).isActive = true
    }

    fileprivate func setupPricingLabel() {
        addSubview(pricingLabel)
        pricingLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        pricingLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        pricingLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 10).isActive = true
        pricingLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    func load(_ model: PoiDetailsModelProtocol) {
        titleLabel.text = model.poiName
        categoryLabel.text = model.category
        addressLabel.text = model.address

        let pricingString = NSMutableAttributedString(string: "Pricing: ",
                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        let pricingValueString = NSAttributedString(string: "\(String(format: "%.2f", model.pricing))/\(Int(model.maxPricing))",
                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)])
        pricingString.append(pricingValueString)
        pricingLabel.attributedText = pricingString

        let ratingString = NSMutableAttributedString(string: "Rating: ",
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        let ratingValueString = NSAttributedString(string: "\(String(format: "%.2f", model.rating))/\(Int(model.maxRating)) (\(Int(model.reviews.count)) ratings)",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)])
        ratingString.append(ratingValueString)
        ratingLabel.attributedText = ratingString
    }

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupTitleLabel()
        setupCategoryLabel()
        setupAddressLabel()
        setupRatingLabel()
        setupPricingLabel()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
