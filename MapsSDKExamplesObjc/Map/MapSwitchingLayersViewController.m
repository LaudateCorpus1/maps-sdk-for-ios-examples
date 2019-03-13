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

#import "MapSwitchingLayersViewController.h"
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>

@interface MapSwitchingLayersViewController ()

@end

@implementation MapSwitchingLayersViewController

- (void)onMapReady {
    [self turnOffLayers];
}

- (void)setupCenterOnWillHappen {
    [self.mapView centerOnCoordinate:[TTCoordinate BERLIN] withZoom:8];
}

- (OptionsView *)getOptionsView {
    return [[OptionsViewMultiSelect alloc] initWithLabels:@[@"Road network", @"Woodland", @"Build-up"] selectedID:-1];
}



- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    switch (ID) {
        case 2:
            [self.mapView setVisible:on ofSourceLayers:@"Built-up area"];
            break;
        case 1:
            [self.mapView setVisible:on ofSourceLayers:@"Woodland.*"];
            break;
        default:
            [self.mapView setVisible:on ofSourceLayers:@".*road.*"];
            [self.mapView setVisible:on ofSourceLayers:@".*Road.*"];
            [self.mapView setVisible:on ofSourceLayers:@".*Motorway.*"];
            [self.mapView setVisible:on ofSourceLayers:@".*motorway.*"];
            break;
    }
}



- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)turnOffLayers {
    [self.mapView setVisible:NO ofSourceLayers:@"Built-up area"];
    [self.mapView setVisible:NO ofSourceLayers:@"Woodland.*"];
    [self.mapView setVisible:NO ofSourceLayers:@".*road.*"];
    [self.mapView setVisible:NO ofSourceLayers:@".*Road.*"];
    [self.mapView setVisible:NO ofSourceLayers:@".*Motorway.*"];
    [self.mapView setVisible:NO ofSourceLayers:@".*motorway.*"];
}


@end
