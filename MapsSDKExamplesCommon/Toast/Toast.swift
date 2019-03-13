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

public class Toast: NSObject {
    
    weak var window: UIWindow!
    weak var toastView: ToastView!
    var timer: Timer!

    public override init() {
        window = UIApplication.shared.windows.last!
    }

    @objc public func toast(message: String) {
        if toastView == nil {
            let toastView = ToastView()
            window.addSubview(toastView)
            self.toastView = toastView
            let superView = toastView.superview!
            toastView.translatesAutoresizingMaskIntoConstraints = false
            toastView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            toastView.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -40).isActive = true
            toastView.centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
            toastView.widthAnchor.constraint(equalToConstant: 280).isActive = true
        }
        toastView.text = message

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
            self.dismiss()
        })
    }
    
    @objc public func dismiss() {
        toastView?.removeFromSuperview()
        timer.invalidate()
    }

}
