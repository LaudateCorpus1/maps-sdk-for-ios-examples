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

public class ProgressImageView: UIImageView {
    
    weak var activityIndicator: UIActivityIndicatorView!

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.isHidden = false
        activityIndicator.color = TTColor.Black()
        activityIndicator.startAnimating()
        addSubview(activityIndicator)
        self.activityIndicator = activityIndicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 80).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }

    override public var image: UIImage? {
        didSet {
            activityIndicator.removeFromSuperview()
        }
    }
}
