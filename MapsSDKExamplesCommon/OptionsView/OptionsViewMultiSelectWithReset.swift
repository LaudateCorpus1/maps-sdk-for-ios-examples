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

public class OptionsViewMultiSelectWithReset: OptionsView {
    
    @objc override func buttonTouchUpInside(button: UIButton) {
        guard let last = buttons.last else {
            return
        }
        
        if button == last {
            if last.isSelected {
                return
            } else {
                deselectAll()
                selectAndTriggerDelegateFor(last, selected: true)
            }
        }
        
        if button != last {
            last.isSelected = false
            selectAndTriggerDelegateFor(button, selected: !button.isSelected)
        }
        
        if !isAnySelected {
            selectAndTriggerDelegateFor(last, selected: true)
        }
    }
    
    var isAnySelected: Bool {
        get {
            for button in buttons {
                if button.isSelected {
                    return true
                }
            }
            return false
        }
    }
    
}
