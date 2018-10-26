/**
 * Copyright (c) 2018 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its subsidiaries and may be used
 * for internal evaluation purposes or commercial use strictly subject to separate licensee
 * agreement between you and TomTom. If you are the licensee, you are only permitted to use
 * this Software in accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and should
 * immediately return it to TomTom N.V.
 */

import UIKit

public class ActionSheet: NSObject {
    
    let toast: Toast
    let viewController: UIViewController
    
    @objc public init(toast: Toast, viewController: UIViewController) {
        self.toast = toast
        self.viewController = viewController
        super.init()
    }
    
    @objc public func show(result: @escaping (Date?) -> Void) {
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        let timeInternal: TimeInterval = 5 * 60 * 60 //+5h
        let pickerInitialDate = Date().addingTimeInterval(timeInternal)
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        alertController.view.addSubview(picker)
        picker.date = pickerInitialDate
        picker.minuteInterval = 5
        
        let actionOk = UIAlertAction(title: "OK", style: .default) { (_) in
            if picker.date < Date() {
                self.toast.toast(message: "The departure and arrival can not be in the past")
                result(nil)
            } else {
                result(picker.date)
            }
        }
        alertController.addAction(actionOk)
        
        let actionCancel = UIAlertAction(title: "No, thanks", style: .default) { (_) in
            result(nil)
        }
        alertController.addAction(actionCancel)
        
        viewController.present(alertController, animated: true, completion: nil)
    }

}
