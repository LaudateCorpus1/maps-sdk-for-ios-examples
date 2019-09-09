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

import TomTomOnlineSDKMaps
import UIKit

public class CustomCallout: UIView, TTCalloutView {
    public var annotation: TTAnnotation?
    public var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)

    public init(frame: CGRect, cooridnate: CLLocationCoordinate2D) {
        self.coordinate = cooridnate
        super.init(frame: frame)
        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let contentView = Bundle.main.loadNibNamed("CustomCallout", owner: self, options: nil)?.first as! UIView
        self.bounds = contentView.bounds
        addSubview(contentView)
        backgroundColor = TTColor.White()
        layer.shadowColor = TTColor.Black().cgColor
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowOpacity = 1
    }
}
