/**
 * Copyright (c) 2020 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its
 * subsidiaries and may be used for internal evaluation purposes or commercial
 * use strictly subject to separate licensee agreement between you and TomTom.
 * If you are the licensee, you are only permitted to use this Software in
 * accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and
 * should immediately return it to TomTom N.V.
 */

#import "MapPoiLayersVisibilityViewController.h"
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>

@interface MapPoiLayersVisibilityViewController ()
@property TTMapStyle *currentStyle;
@end

@implementation MapPoiLayersVisibilityViewController

- (void)setupMap {
    [super setupMap];
    _currentStyle = self.mapView.styleManager.currentStyle;
}

- (void)onMapReady {
    [super onMapReady];
    TTBoundingBox *boundingBox = [[TTBoundingBox alloc] initWithTopLeft:[TTCoordinate BERLIN_BOUNDINGBOX_LT] withBottomRight:[TTCoordinate BERLIN_BOUNDINGBOX_RB]];
    TTCameraBoundingBox *cameraPosition = [[TTCameraBoundingBoxBuilder createWithBoundingBox:boundingBox] build];
    [self.mapView setCameraPosition:cameraPosition];
    [self.mapView.poiDisplay turnOnRichPoiLayer];
}

- (void)setupInitialCameraPosition {
}

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"All POI", @"No POI", @"Parks" ] selectedID:0];
}

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    switch (ID) {
    case 0:
        [self.mapView.poiDisplay show];
        break;
    case 1:
        [self.mapView.poiDisplay hide];
        break;
    default:
        [self.mapView.poiDisplay hide];
        [self.mapView.poiDisplay show:@[ @"Park & Recreation Area" ]];
        break;
    }
}

@end
