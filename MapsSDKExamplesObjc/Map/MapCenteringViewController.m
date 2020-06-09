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
#import "MapCenteringViewController.h"

@implementation MapCenteringViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self centerOnAmsterdam];
}
- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"Amsterdam", @"Berlin", @"Bounding box" ] selectedID:0];
}
- (void)setupInitialCameraPosition {
}
#pragma mark OptionsViewDelegate
- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    switch (ID) {
    case 2:
        [self boundingBoxOnAmsterdam];
        break;
    case 1:
        [self centerOnBerlin];
        break;
    default:
        [self centerOnAmsterdam];
        break;
    }
}
#pragma mark Examples
- (void)centerOnAmsterdam {
    TTCameraPosition *cameraPosition = [[[TTCameraPositionBuilder createWithCameraPosition:[TTCoordinate AMSTERDAM]] withZoom:10] build];
    [self.mapView setCameraPosition:cameraPosition];
}
- (void)centerOnBerlin {
    TTCameraPosition *cameraPosition = [[[TTCameraPositionBuilder createWithCameraPosition:[TTCoordinate BERLIN]] withZoom:10] build];
    [self.mapView setCameraPosition:cameraPosition];
}
- (void)boundingBoxOnAmsterdam {
    TTBoundingBox *boundingBox = [[TTBoundingBox alloc] initWithTopLeft:[TTCoordinate AMSTERDAM_BOUNDINGBOX_LT] withBottomRight:[TTCoordinate AMSTERDAM_BOUNDINGBOX_RB]];
    TTCameraBoundingBox *cameraPosition = [[TTCameraBoundingBoxBuilder createWithBoundingBox:boundingBox] build];
    [self.mapView setCameraPosition:cameraPosition];
}
@end
