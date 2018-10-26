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

#import "MapUIExtensionsViewController.h"
#import <TomTomOnlineSDKMapsUIExtensions/TomTomOnlineSDKMapsUIExtensions.h>

@interface MapUIExtensionsViewController()
@property (nonatomic, weak) TTControlView *controlView;
@end

@implementation MapUIExtensionsViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[@"Default", @"Custom", @"Hide"] selectedID:0];
}

- (void)setupMap {
    [super setupMap];
    TTControlView *controlView = [TTControlView new];
    controlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    controlView.mapView = self.mapView;
    [self.view addSubview:controlView];
    self.controlView = controlView;
    [self controlsDefault];
}

- (void)setupCenterOnWillHappen {
    TTCameraPosition *cameraPosition = [[TTCameraPosition alloc] initWithCamerPosition:[TTCoordinate AMSTERDAM] withAnimationDuration:0 withBearing:45 withPitch:0 withZoom:10];
    [self.mapView setCameraPosition:cameraPosition];
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    switch (ID) {
        case 2:
            [self controlsHidden];
            break;
        case 1:
            [self controlsCustom];
            break;
        default:
            [self controlsDefault];
            break;
    }
}

#pragma mark Examples

- (void)controlsDefault {
    self.controlView.centerButton.hidden = NO;
    self.controlView.compassButton.hidden = NO;
    self.controlView.zoomView.hidden = NO;
    self.controlView.controlView.hidden = NO;
    [self.controlView initDefaultCenterButton];
    [self.controlView initDefaultCompassButton];
    [self.controlView initDefaultTTPanControlView];
    [self.controlView initDefaultTTZoomView];
    self.controlView.topLayoutConstraintCompassButton.constant = 70;
    self.controlView.bottomLayoutConstraintCenterButton.constant = -70;
}

- (void)controlsCustom {
    self.controlView.centerButton.hidden = NO;
    self.controlView.compassButton.hidden = NO;
    self.controlView.zoomView.hidden = NO;
    self.controlView.controlView.hidden = NO;
    
    UIButton *customCurrentLocationButton = [UIButton new];
    [customCurrentLocationButton setImage:[UIImage imageNamed:@"custom_current_location"] forState:UIControlStateNormal];
    [customCurrentLocationButton setImage:[UIImage imageNamed:@"custom_current_location"] forState:UIControlStateHighlighted];
    self.controlView.centerButton = customCurrentLocationButton;
    self.controlView.bottomLayoutConstraintCenterButton.constant = -70;
    
    UIButton *customCompassButton = [UIButton new];
    [customCompassButton setImage:[UIImage imageNamed:@"custom_compass"] forState:UIControlStateNormal];
    [customCompassButton setImage:[UIImage imageNamed:@"custom_compass"] forState:UIControlStateHighlighted];
    [customCompassButton setImage:[UIImage imageNamed:@"custom_compass"] forState:UIControlStateSelected];
    self.controlView.compassButton = customCompassButton;
    self.controlView.topLayoutConstraintCompassButton.constant = 70;
    
    UIButton *customControlLeftButton = [UIButton new];
    [customControlLeftButton setImage:[UIImage imageNamed:@"arrow_left_custom"] forState:UIControlStateNormal];
    [customControlLeftButton setImage:[UIImage imageNamed:@"arrow_down_highlighted_custom"] forState:UIControlStateHighlighted];
    self.controlView.controlView.leftControlBtn = customControlLeftButton;
    UIButton *customControlRightButton = [UIButton new];
    [customControlRightButton setImage:[UIImage imageNamed:@"arrow_right_custom"] forState:UIControlStateNormal];
    [customControlRightButton setImage:[UIImage imageNamed:@"arrow_right_highlighted_custom"] forState:UIControlStateHighlighted];
    self.controlView.controlView.rightControlBtn = customControlRightButton;
    
    UIButton *customControlUpButton = [UIButton new];
    [customControlUpButton setImage:[UIImage imageNamed:@"arrow_up_custom"] forState:UIControlStateNormal];
    [customControlUpButton setImage:[UIImage imageNamed:@"arrow_up_highlighted_custom"] forState:UIControlStateHighlighted];
    self.controlView.controlView.upControlBtn = customControlUpButton;
    
    UIButton *customControlDownButton = [UIButton new];
    [customControlDownButton setImage:[UIImage imageNamed:@"arrow_down_custom"] forState:UIControlStateNormal];
    [customControlDownButton setImage:[UIImage imageNamed:@"arrow_down_highlighted_custom"] forState:UIControlStateHighlighted];
    self.controlView.controlView.downControlBtn = customControlDownButton;
    
    UIButton *customControlZoomInButton = [UIButton new];
    [customControlZoomInButton setImage:[UIImage imageNamed:@"zoom_in_custom"] forState:UIControlStateNormal];
    [customControlZoomInButton setImage:[UIImage imageNamed:@"zoom_in_highlighted_custom"] forState:UIControlStateHighlighted];
    self.controlView.zoomView.zoomIn = customControlZoomInButton;
    UIButton *customControlZoomOutButton = [UIButton new];
    [customControlZoomOutButton setImage:[UIImage imageNamed:@"zoom_out_custom"] forState:UIControlStateNormal];
    [customControlZoomOutButton setImage:[UIImage imageNamed:@"zoom_out_highlighted_custom"] forState:UIControlStateHighlighted];
    self.controlView.zoomView.zoomOut = customControlZoomOutButton;
}

- (void)controlsHidden {
    self.controlView.centerButton.hidden = YES;
    self.controlView.compassButton.hidden = YES;
    self.controlView.zoomView.hidden = YES;
    self.controlView.controlView.hidden = YES;
}

@end
