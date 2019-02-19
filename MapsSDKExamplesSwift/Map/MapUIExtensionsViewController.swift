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
import MapsSDKExamplesCommon
import MapsSDKExamplesVC
import TomTomOnlineSDKMapsUIExtensions

class MapUIExtensionsViewController: MapBaseViewController {
    
    weak var controlView: TTControlView!

    override func getOptionsView() -> OptionsView {
        return OptionsViewSingleSelect(labels: ["Default", "Custom", "Hide"], selectedID: 0)
    }
    
    override func setupMap() {
        super.setupMap()
        let controlView = TTControlView()
        controlView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        controlView.mapView = mapView
        view.addSubview(controlView)
        self.controlView = controlView
        controlsDefault()
    }
    
    override func setupCenterOnWillHappen() {
        let cameraPosition = TTCameraPositionBuilder.create(withCameraPosition: TTCoordinate.AMSTERDAM())
            .withBearing(45)
            .withZoom(10)
            .build()
        
        mapView.setCameraPosition(cameraPosition)
    }
    
    //MARK: OptionsViewDelegate
    
    override func displayExample(withID ID: Int, on: Bool) {
        super.displayExample(withID: ID, on: on)
        switch ID {
        case 2:
            controlsHidden()
        case 1:
            controlsCustom()
        default:
            controlsDefault()
        }
    }
    
    //MARK: Examples
    
    func controlsDefault() {
        controlView.centerButton?.isHidden = false
        controlView.compassButton?.isHidden = false
        controlView.zoomView?.isHidden = false
        controlView.controlView?.isHidden = false
        controlView.initDefaultCenterButton()
        controlView.initDefaultCompassButton()
        controlView.initDefaultTTPanControlView()
        controlView.initDefaultTTZoom()
        controlView.topLayoutConstraintCompassButton?.constant = 70
        controlView.bottomLayoutConstraintCenterButton?.constant = -70
    }
    
    func controlsCustom() {
        controlView.centerButton?.isHidden = false
        controlView.compassButton?.isHidden = false
        controlView.zoomView?.isHidden = false
        controlView.controlView?.isHidden = false
        
        let customCurrentLocationButton = UIButton()
        customCurrentLocationButton.setImage(UIImage(named: "custom_current_location"), for: .normal)
        customCurrentLocationButton.setImage(UIImage(named: "custom_current_location"), for: .highlighted)
        controlView.centerButton = customCurrentLocationButton
        controlView.bottomLayoutConstraintCenterButton?.constant = -70
        
        let customCompassButton = UIButton()
        customCompassButton.setImage(UIImage(named: "custom_compass"), for: .normal)
        customCompassButton.setImage(UIImage(named: "custom_compass"), for: .highlighted)
        customCompassButton.setImage(UIImage(named: "custom_compass"), for: .selected)
        controlView.compassButton = customCompassButton
        controlView.topLayoutConstraintCompassButton?.constant = 70
        
        let customControlLeftButton = UIButton()
        customControlLeftButton.setImage(UIImage(named: "arrow_left_custom"), for: .normal)
        customControlLeftButton.setImage(UIImage(named: "arrow_left_highlighted_custom"), for: .highlighted)
        controlView.controlView?.leftControlBtn = customControlLeftButton
        let customControlRightButton = UIButton()
        customControlRightButton.setImage(UIImage(named: "arrow_right_custom"), for: .normal)
        customControlRightButton.setImage(UIImage(named: "arrow_right_highlighted_custom"), for: .highlighted)
        controlView.controlView?.rightControlBtn = customControlRightButton
        
        let customControlUpButton = UIButton()
        customControlUpButton.setImage(UIImage(named: "arrow_up_custom"), for: .normal)
        customControlUpButton.setImage(UIImage(named: "arrow_up_highlighted_custom"), for: .highlighted)
        controlView.controlView?.upControlBtn = customControlUpButton
        
        let customControlDownButton = UIButton()
        customControlDownButton.setImage(UIImage(named: "arrow_down_custom"), for: .normal)
        customControlDownButton.setImage(UIImage(named: "arrow_down_highlighted_custom"), for: .highlighted)
        controlView.controlView?.downControlBtn = customControlDownButton
        
        let customControlZoomInButton = UIButton()
        customControlZoomInButton.setImage(UIImage(named: "zoom_in_custom"), for: .normal)
        customControlZoomInButton.setImage(UIImage(named: "zoom_in_highlighted_custom"), for: .highlighted)
        controlView.zoomView?.zoomIn = customControlZoomInButton
        let customControlZoomOutButton = UIButton()
        customControlZoomOutButton.setImage(UIImage(named: "zoom_out_custom"), for: .normal)
        customControlZoomOutButton.setImage(UIImage(named: "zoom_out_highlighted_custom"), for: .highlighted)
        controlView.zoomView?.zoomOut = customControlZoomOutButton
    }
    
    func controlsHidden() {
        controlView.centerButton?.isHidden = true
        controlView.compassButton?.isHidden = true
        controlView.zoomView?.isHidden = true
        controlView.controlView?.isHidden = true
    }

}
