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

public class Progress: NSObject {
    
    weak var window: UIWindow!
    weak var layer: UIView!
    
    public override init() {
        window = UIApplication.shared.windows.last!
    }

    @objc public func show() {
        let layer = UIView()
        layer.backgroundColor = TTColor.Black()
        layer.alpha = 0.5
        window.addSubview(layer)
        self.layer = layer
        layer.translatesAutoresizingMaskIntoConstraints = false
        let superView = layer.superview!
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[v0]-0-|", options: [], metrics: nil, views: ["v0": layer]))
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[v0]-0-|", options: [], metrics: nil, views: ["v0": layer]))
        
        let activitiIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activitiIndicator.color = TTColor.White()
        layer.addSubview(activitiIndicator)
        activitiIndicator.startAnimating()
        activitiIndicator.translatesAutoresizingMaskIntoConstraints = false
        activitiIndicator.centerXAnchor.constraint(equalTo: layer.centerXAnchor).isActive = true
        activitiIndicator.centerYAnchor.constraint(equalTo: layer.centerYAnchor).isActive = true
    }
    
    @objc public func hide() {
        if let layer = self.layer {
            layer.removeFromSuperview()
        }
    }

}
