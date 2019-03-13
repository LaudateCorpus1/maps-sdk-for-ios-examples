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

public class TrafficCell: UITableViewCell {

    @IBOutlet public weak var trafficImageView: UIImageView!
    @IBOutlet public weak var trafficDescription: UILabel!
    @IBOutlet public weak var trafficDelay: UILabel!
    @IBOutlet public weak var trafficLength: UILabel!
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let content = Bundle(for: type(of: self)).loadNibNamed("TrafficCell", owner: self, options: nil)?.first as! UIView
        addSubview(content)
        content.frame = bounds
    }
    
}
