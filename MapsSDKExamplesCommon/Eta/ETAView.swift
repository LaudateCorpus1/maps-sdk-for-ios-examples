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

public class ETAView: UIView {
    @objc public enum ETAViewStyle: Int {
        case plain
        case arrival
        case consumptionKWh
        case consumptionLiters
    }

    @IBOutlet var leftIcon: UIImageView!
    @IBOutlet var distance: UILabel!
    @IBOutlet var time: UILabel!

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let contentView = Bundle.main.loadNibNamed("ETAView", owner: self, options: nil)?.first as! UIView
        self.bounds = contentView.bounds
        addSubview(contentView)
        isHidden = true
    }

    @objc public func show(summary: TTSummary, style: ETAView.ETAViewStyle) {
        let components = summary.arrivalTime.components
        switch style {
        case .consumptionLiters:
            time.text = "Consumption \(String(format: "%.2f", summary.fuelConsumptionInLitersValue)) liters"
            if let leftIcon = leftIcon {
                leftIcon.removeFromSuperview()
            }
        case .consumptionKWh:
            time.text = "Consumption \(String(format: "%.2f", summary.batteryConsumptionInkWhValue)) kWh"
            if let leftIcon = leftIcon {
                leftIcon.removeFromSuperview()
            }
        case .arrival:
            time.text = String(format: "%02d:%02d", components.hour, components.minute)
            leftIcon.image = UIImage(named: "ArriveAt")!
        default:
            time.text = String(format: "%02d:%02d", components.hour, components.minute)
            leftIcon.image = UIImage(named: "Destination")!
        }
        distance.text = "\(FormatUtils.formatDistance(meters: UInt(summary.lengthInMetersValue)))"
        isHidden = false
    }

    @objc public func update(eta: String, metersDistance: UInt) {
        time.text = eta
        distance.text = "\(FormatUtils.formatDistance(meters: metersDistance))"
        isHidden = false
    }

    @objc public func update(text: String, icon: UIImage) {
        time.text = text
        time.font = UIFont(name: time.font.fontName, size: 12)
        leftIcon.image = icon
        leftIcon.contentMode = .center
        if distance != nil {
            distance.removeFromSuperview()
        }
        isHidden = false
    }

    @objc public func hide() {
        isHidden = true
    }
}
