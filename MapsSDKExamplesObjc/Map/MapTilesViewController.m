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

#import "MapTilesViewController.h"

@implementation MapTilesViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"Vector", @"Raster" ] selectedID:0];
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    switch (ID) {
    case 1:
        [self displayRaster];
        break;
    default:
        [self displayVectors];
        break;
    }
}

#pragma mark Examples

- (void)displayVectors {
    TTMapStyleConfiguration *configuration = [[TTMapStyleConfigurationBuilder createWithStyleURL:@"asset://../../vector_style.json"] build];
    [self.mapView.styleManager loadStyleConfiguration:configuration withCompletion:nil];
}

- (void)displayRaster {
    TTMapStyleConfiguration *configuration = [[TTMapStyleConfigurationBuilder createWithStyleURL:@"asset://../../mapssdk-raster-layers.json"] build];
    [self.mapView.styleManager loadStyleConfiguration:configuration withCompletion:nil];
}

@end
