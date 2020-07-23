//
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

import UIKit

public class MultiLineCalloutView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 10)
        label.numberOfLines = 0
        return label
    }()

    @objc public init(text: String, title: String, calloutSize: CGSize) {
        super.init(frame: .init(origin: .zero, size: calloutSize))

        addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        titleLabel.text = title
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)

        addSubview(textLabel)
        textLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        textLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        textLabel.text = text
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
