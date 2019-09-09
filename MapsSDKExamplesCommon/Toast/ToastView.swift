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

class ToastView: UILabel {
    let verticalPadding: CGFloat = 0
    let horizontalPadding: CGFloat = 10

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        numberOfLines = 0
        font = UIFont(name: "Menlo", size: 14)
        textAlignment = .center
        backgroundColor = TTColor.White()
        textColor = TTColor.Black()
        layer.shadowOpacity = 1
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize.zero
        layer.shadowColor = TTColor.Black().cgColor
    }
}
