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

class MatrixRow: UITableViewCell {
    @IBOutlet var label_1: UILabel!
    @IBOutlet var label_2: UILabel!
    @IBOutlet var label_3: UILabel!
    @IBOutlet var label_4: UILabel!
    @IBOutlet var label_5: UILabel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let content = Bundle.main.loadNibNamed("MatrixRow", owner: self, options: nil)?.first as! UIView
        addSubview(content)
        content.frame = self.bounds
    }

    @objc public func update(columns: [String]) {
        label_1.text = columns[0]
        label_2.text = columns[1]
        label_3.text = columns[2]
        label_4.text = columns[3]
        label_5.text = columns[4]
    }
}
