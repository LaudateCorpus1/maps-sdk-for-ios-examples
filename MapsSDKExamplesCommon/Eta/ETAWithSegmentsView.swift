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

import TomTomOnlineSDKRouting
import UIKit

public class ETAWithSegmentsView: UIView {
    weak var etaView: ETAView!
    @objc public weak var segments: UISegmentedControl!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let etaView = ETAView()
        etaView.isHidden = false
        self.etaView = etaView
        addSubview(etaView)
        etaView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[v0]-0-|", options: [], metrics: nil, views: ["v0": etaView]))
        etaView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let segments = UISegmentedControl(items: ["🇬🇧 EN", "🇩🇪 DE", "🇪🇸 ES", "🇫🇷 FR"])
        segments.tintColor = TTColor.GreenLight()
        self.segments = segments
        addSubview(segments)
        segments.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[v0]-0-|", options: [], metrics: nil, views: ["v0": segments]))
        segments.heightAnchor.constraint(equalToConstant: 30).isActive = true
        segments.topAnchor.constraint(equalTo: etaView.bottomAnchor).isActive = true
    }

    @objc public func addTarget(_ target: Any?, action: Selector) {
        segments.addTarget(target, action: action, for: .valueChanged)
    }

    @objc public func show(summary: TTSummary) {
        etaView.show(summary: summary, style: .plain)
    }
}
