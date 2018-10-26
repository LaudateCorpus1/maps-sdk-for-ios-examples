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

import Foundation

public class FormatUtils: NSObject {
    
    @objc public static func formatTimeDelay(seconds: Int) -> String {
        if seconds >= 3600 {
            let hours = seconds / 3600
            let minutes = (seconds % 3600) / 60
            return "\(hours) h \(minutes) min"
        } else {
            let minutes = seconds / 60
            let sec = seconds % 60
            if minutes > 0 {
                return "\(minutes) min \(sec) s"
            } else {
                return "\(sec) s"
            }
        }
    }
    
    @objc public static func formatDistance(meters: UInt) -> String {

        var fValue:Float = 0.0
        var iValue:Int = 0
        var unit:String?
        var value:String = ""
        var combined:String = ""
    
        if Locale.current.usesMetricSystem == false { //MILES
            
            let meters = Measurement(value: Double(meters), unit: UnitLength.meters)
            
            if meters.converted(to: UnitLength.feet).value <= 500 {
                iValue = Int(meters.converted(to: UnitLength.feet).value)
                unit = "ft"
            } else {
                fValue = Float(meters.converted(to: UnitLength.miles).value)
                unit = "mi"
            }
        } else { // KM
            if meters <= 500 {
                iValue = Int((meters > 0) ? meters : 1)
                unit = "m"
            } else {
                fValue = Float(Measurement(value: Double(meters), unit: UnitLength.meters).converted(to: UnitLength.kilometers).value)
                unit = "km"
            }
        }
        
        
        if fValue != 0.0 {
            var formatter:NumberFormatter? = nil
            if (formatter == nil) {
                formatter = NumberFormatter()
                formatter?.maximumFractionDigits = 1
                formatter?.minimumIntegerDigits = 1
                formatter?.usesGroupingSeparator = true
                formatter?.groupingSize = 3
            }
            value = (formatter?.string(from: NSNumber(value: fValue)))!
        } else {
            value = "\(iValue)"
        }
        
        combined = "\(value) " + unit!
        
        return combined
    }

}
