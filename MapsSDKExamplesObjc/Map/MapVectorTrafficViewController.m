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

#import "MapVectorTrafficViewController.h"

@implementation MapVectorTrafficViewController

- (void)setupCenterOnWillHappen {
    [self.mapView centerOnCoordinate:[TTCoordinate LONDON] withZoom:12];
}

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[@"Flow", @"No traffic"] selectedID:1];
}

- (void)setupMap {
    [super setupMap];
    [self.mapView setTilesType:TTMapTilesVector];
    self.mapView.trafficTileStyle = [TTVectorTileType setStyle:TTVectorStyleRelative];
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    switch (ID) {
        case 1:
            [self hideFlow];
            break;
        default:
            if (on) {
                [self displayFlow];
            } else {
                [self hideFlow];
            }
            break;
    }
}

#pragma mark Examples

- (void)displayFlow {
    self.mapView.trafficFlowOn = YES;
}

- (void)hideFlow {
    self.mapView.trafficFlowOn = NO;
}

@end
