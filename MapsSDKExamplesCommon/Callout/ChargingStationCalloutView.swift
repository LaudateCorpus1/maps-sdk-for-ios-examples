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

@objc public class ChargingStationCalloutView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .left
        return label
    }()

    private lazy var waitTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12)
        return label
    }()

    private lazy var flagIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "flag_icon")
        imageView.contentMode = .center
        return imageView
    }()

    @objc public init(text: String, title: String) {
        let height: CGFloat = 70
        super.init(frame: .init(origin: .zero, size: .init(width: 270, height: height)))
        backgroundColor = .black

        addSubview(flagIcon)
        flagIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        flagIcon.topAnchor.constraint(equalTo: topAnchor).isActive = true
        flagIcon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        flagIcon.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        addSubview(titleLabel)
        titleLabel.text = title
        titleLabel.leftAnchor.constraint(equalTo: flagIcon.rightAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: height / 2).isActive = true

        addSubview(waitTimeLabel)
        waitTimeLabel.leftAnchor.constraint(equalTo: flagIcon.rightAnchor).isActive = true
        waitTimeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        waitTimeLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        //  waitTimeLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        waitTimeLabel.text = text
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
