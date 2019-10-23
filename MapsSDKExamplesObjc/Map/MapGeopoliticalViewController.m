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

#import "MapGeopoliticalViewController.h"

@implementation MapGeopoliticalViewController

- (void)setupInitialCameraPosition {
  [self.mapView centerOnCoordinate:[TTCoordinate ISRAEL] withZoom:7];
}

- (OptionsView *)getOptionsView {
  return
      [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"Unified", @"Local" ]
                                           selectedID:0];
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
  [super displayExampleWithID:ID on:on];
  switch (ID) {
  case 1:
    [self displayGeopoliticalViewLocal];
    break;
  default:
    [self displayGeopoliticalViewInternational];
    break;
  }
}

#pragma mark Examples

- (void)displayGeopoliticalViewInternational {
  [self.mapView setGeopoliticalView:TTGeoViewNone];
}

- (void)displayGeopoliticalViewLocal {
  [self.mapView setGeopoliticalView:TTGeoViewIL];
}

@end
