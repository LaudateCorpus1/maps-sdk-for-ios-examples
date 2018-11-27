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
import CoreLocation

public class TTColor: NSObject {
    
    @objc public static func White() -> UIColor { return UIColor.white }
    @objc public static func Black() -> UIColor { return UIColor.black }
    @objc public static func BlackLight() -> UIColor { return UIColor(red: 0.1882, green: 0.1882, blue: 0.1882, alpha: 1.0) }
    @objc public static func Gray() -> UIColor { return UIColor(red: 0.3294, green: 0.3294, blue: 0.3255, alpha: 1.0) }
    @objc public static func GrayLight() -> UIColor { return UIColor(red: 0.3294, green: 0.3294, blue: 0.3255, alpha: 1.0) }
    @objc public static func GreenLight() -> UIColor { return UIColor(red: 0.7412, green: 0.8431, blue: 0.1922, alpha: 1.0) }
    @objc public static func GreenDark() -> UIColor { return UIColor(red: 0.4784, green: 0.6627, blue: 0.1254, alpha: 1.0) }
    @objc public static func Red() -> UIColor { return UIColor(red: 1, green: 0, blue: 0, alpha: 1.0) }
    @objc public static func RedSemiTransparent() -> UIColor { return UIColor(red: 1, green: 0, blue: 0, alpha: 0.3) }
    
}

struct TTCollectionViewCell {
    
    static let UIEdgeInsetTop: CGFloat = 8.0
    static let UIEdgeInsetBottom: CGFloat = 8.0
    static let UIEdgeInsetLeft: CGFloat = 8.0
    static let UIEdgeInsetRight: CGFloat = 8.0
    
    static let HeightPortrait: CGFloat = 150.0
    static let HeightLandscape: CGFloat = 125.0
    
    static let OptionHeightPortrait: CGFloat = 300.0
    static let OptionHeightLandscape: CGFloat = 250.0
    
}

public class TTCoordinate: NSObject {

    @objc public static func LODZ_SENKIEWICZA() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(51.7689803,19.4245332) }
    @objc public static func LODZ_DREWNOWSKA() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(51.7797617,19.444442) }
    @objc public static func LODZ() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(51.773097,19.4105534) }
    @objc public static func LODZ_ZEROMSKIEGO() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(51.759434,19.449011) }
    @objc public static func LONDON() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(51.507351, -0.127758) }
    @objc public static func LONDON_TOP_LEFT() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(51.544300, -0.176267) }
    @objc public static func LONDON_BOTTOM_RIGHT() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(51.465582, -0.071777) }
    @objc public static func BERLIN() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(52.520007, 13.404954) }
    @objc public static func POLAND() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(51.9324518, 16.8922826) }
    @objc public static func AMSTERDAM() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(52.377271, 4.909466) }
    @objc public static func AMSTERDAM_CENTER_LOCATION() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(52.373154, 4.890659) }
    @objc public static func AMSTERDAM_CIRCLE() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(52.3639871,4.7953232) }
    @objc public static func AMSTERDAM_A10() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(52.3691851,4.8505632) }
    @objc public static func HAARLEM() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(52.381222, 4.637558) }
    @objc public static func AMSTERDAM_POLYGON_1() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(52.388658, 4.859119) }
    @objc public static func AMSTERDAM_POLYGON_2() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(52.346523, 4.858432) }
    @objc public static func AMSTERDAM_POLYGON_3() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(52.352185, 4.908557) }
    @objc public static func ISRAEL() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(32.009929, 34.843555) }
    @objc public static func INDIA() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(23.605569, 68.512920) }
    @objc public static func BRUSSELS() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(50.854954, 4.3051791) }
    @objc public static func HAMBURG() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(53.5584902, 9.7877407) }
    @objc public static func ZURICH() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(47.3774336, 8.466504) }
    @objc public static func OSLO() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(59.911491,10.757933) }
    @objc public static func AMSTERDAM_TOMTOM() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(52.376368, 4.908113) }
    @objc public static func ROTTERDAM() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(51.935966, 4.482865) }
    @objc public static func AMSTERDAM_A10_START() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(52.345971, 4.844899) }
    @objc public static func AMSTERDAM_A10_STOP() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(52.372281, 4.846595) }
    @objc public static func UTRECHT() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(52.09179, 5.11457) }
    @objc public static func HOOFDDORP() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(52.3058782, 4.6483191) }
    @objc public static func NORTH_SEA() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(54.929440, 6.464524) }
    @objc public static func ALPHEN_AAN_DEN_RIJN() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(52.128247, 4.668368) }
    @objc public static func PORTUGAL_COIMBRA() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(40.209408, -8.423741) }
    @objc public static func PORTUGAL_NOVA() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(40.10995732392718, -8.501433134078981) }
    @objc public static func LODZ_SREBRZYNSKA_START() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(51.772756, 19.423065) }
    @objc public static func LODZ_SREBRZYNSKA_WAYPOINT_A() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(51.780990, 19.451229) }
    @objc public static func LODZ_SREBRZYNSKA_WAYPOINT_B() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(51.786451, 19.449562) }
    @objc public static func LODZ_SREBRZYNSKA_WAYPOINT_C() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(51.791383, 19.420641) }
    @objc public static func LODZ_SREBRZYNSKA_STOP() -> CLLocationCoordinate2D { return CLLocationCoordinate2DMake(51.773136, 19.4233983) }
}

public class TTCamera: NSObject {
    @objc public static func ANIMATION_TIME() -> Int32 {
        return 1
    }
    @objc public static func BEARING_START() -> Double {
        return 0
    }
    @objc public static func DEFAULT_MAP_ZOOM_LEVEL_FOR_EXAMPLE() -> Double {
        return 12
    }
    @objc public static func DEFAULT_MAP_ZOOM_LEVEL_FOR_DRIVING() -> Int32 {
        return 17
    }
    @objc public static func DEFAULT_MAP_PITCH_LEVEL_FOR_DRIVING() -> Double {
        return 50
    }
    @objc public static func DEFAULT_VERTICAL_PADDING() -> CGFloat {
        return 30.0
    }
    @objc public static func DEFAULT_HORIZONTAL_PADDING() -> CGFloat {
        return 10.0
    }
    @objc public static func MAP_DEFAULT_INSETS() -> UIEdgeInsets {
        return UIEdgeInsetsMake(TTCamera.DEFAULT_VERTICAL_PADDING() * UIScreen.main.scale, TTCamera.DEFAULT_HORIZONTAL_PADDING() * UIScreen.main.scale, TTCamera.DEFAULT_VERTICAL_PADDING() * UIScreen.main.scale, TTCamera.DEFAULT_HORIZONTAL_PADDING() * UIScreen.main.scale);
    }
}
