/**
 * Copyright (c) 2019 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its
 * subsidiaries and may be used for internal evaluation purposes or commercial
 * use strictly subject to separate licensee agreement between you and TomTom.
 * If you are the licensee, you are only permitted to use this Software in
 * accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and
 * should immediately return it to TomTom N.V.
 */

#import "MapRasterTrafficViewController.h"
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>

@implementation MapRasterTrafficViewController

- (void)setupInitialCameraPosition {
    [self.mapView centerOnCoordinate:[TTCoordinate LONDON] withZoom:12];
}

- (OptionsView *)getOptionsView {
    return [[OptionsViewMultiSelectWithReset alloc] initWithLabels:@[ @"Incidents", @"Flow", @"No traffic" ] selectedID:2];
}

- (void)setupMap {
    [super setupMap];
    [self loadRasterMapTiles];
}

- (void)loadRasterMapTiles {
    __weak MapRasterTrafficViewController *weakSelf = self;
    TTMapStyleConfiguration *configuration = [[TTMapStyleConfigurationBuilder createWithStyleURL:@"asset://../../mapssdk-raster-layers.json"] build];
    [self.mapView.styleManager loadStyleConfiguration:configuration
                                       withCompletion:^{
                                         MapRasterTrafficViewController *strongSelf = weakSelf;
                                         if (!strongSelf)
                                             return;
                                         [strongSelf setupInitialCameraPosition];
                                       }];
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    switch (ID) {
    case 2:
        [self hideIncidents];
        [self hideFlow];
        break;
    case 1:
        if (on) {
            [self displayFlow];
        } else {
            [self hideFlow];
        }
        break;
    default:
        if (on) {
            [self displayIncidents];
        } else {
            [self hideIncidents];
        }
    }
}

#pragma mark Examples

- (void)displayIncidents {
    NSArray<TTMapLayer *> *layers = [self.mapView.styleManager.currentStyle getLayersByRegex:@"tomtom-incidents-layer"];
    for (TTMapLayer *layer in layers) {
        layer.visibility = TTMapLayerVisibilityVisible;
    }
}

- (void)hideIncidents {
    NSArray<TTMapLayer *> *layers = [self.mapView.styleManager.currentStyle getLayersByRegex:@"tomtom-incidents-layer"];
    for (TTMapLayer *layer in layers) {
        layer.visibility = TTMapLayerVisibilityNone;
    }
}

- (void)displayFlow {
    NSArray<TTMapLayer *> *layers = [self.mapView.styleManager.currentStyle getLayersByRegex:@"tomtom-flow-raster-layer"];
    for (TTMapLayer *layer in layers) {
        layer.visibility = TTMapLayerVisibilityVisible;
    }
}

- (void)hideFlow {
    NSArray<TTMapLayer *> *layers = [self.mapView.styleManager.currentStyle getLayersByRegex:@"tomtom-flow-raster-layer"];
    for (TTMapLayer *layer in layers) {
        layer.visibility = TTMapLayerVisibilityNone;
    }
}

@end
