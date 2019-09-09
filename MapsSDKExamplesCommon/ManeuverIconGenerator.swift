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

/**
 This is not accurate implementation of maneuver icon geenration.
 It is only example how this can look like.
 Many of edge cases are not covered here.
 */
public class ManeuverIconGenerator: NSObject {
    @objc public static func imageForInstruction(_ instruction: TTInstruction) -> UIImage {
        var direction: String = ""
        let maneuver = instruction.maneuver
        if maneuver.contains("TURN") || maneuver.contains("SHARP") {
            let myArray = maneuver.components(separatedBy: CharacterSet(charactersIn: "_"))
            direction = String(format: "maneuver_%@_%ld", myArray.last!.lowercased(), labs(instruction.turnAngleInDecimalDegreesValue))
        } else if maneuver.contains("ROUNDABOUT") {
            direction = "maneuver_roundabout_right_\(labs(instruction.turnAngleInDecimalDegreesValue))"
        } else if maneuver.contains("ENTER") {
            direction = "maneuver_left_45"
        } else if maneuver.contains("EXIT") {
            direction = "maneuver_right_45"
        } else if maneuver.contains("ARRIVE") {
            direction = "maneuver_arrival_flag"
        } else {
            direction = "maneuver_straight"
        }
        if let image = UIImage(named: direction) {
            return image
        }
        return UIImage(named: "maneuver_straight")!
    }
}
