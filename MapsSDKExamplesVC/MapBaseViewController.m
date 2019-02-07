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

#import "MapBaseViewController.h"

@implementation MapBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMap];
    [self setupControls];
    __weak MapBaseViewController *weakSelf = self;
    [self.mapView onMapReadyCompletion:^{
        [weakSelf onMapReady];
    }];
}

- (void)setupMap {
    TTMapView *mapView = [[TTMapView alloc] initWithFrame:CGRectZero];
    self.view = mapView;
    self.mapView = mapView;
    self.mapView.accessibilityLabel = @"TTMapView";
    [self setupCenterOnWillHappen];
}

- (void)setupCenterOnWillHappen {
    [self.mapView centerOnCoordinate:[TTCoordinate AMSTERDAM] withZoom:10];
}

- (void)onMapReady {
    self.mapView.showsUserLocation = YES;
}

@end
