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

public class Options: SubOptions {
    @objc public enum Category: Int {
        case Map
        case Traffic
        case Routing
        case Driving
        case Search
        case Geofencing
    }

    let category: Category
    let mainImage: String
    let subOptions: [SubOptions]

    init(category: Category, mainImage: String, iconImage: String, titleLabel: String, subtitleLabel: String, subOptions: [SubOptions]) {
        self.category = category
        self.mainImage = mainImage
        self.subOptions = subOptions
        super.init(iconImage: iconImage, titleLabel: titleLabel, subtitleLabel: subtitleLabel)
    }
}
