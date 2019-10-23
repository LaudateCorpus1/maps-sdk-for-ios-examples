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
  return [[OptionsViewSingleSelect alloc]
      initWithLabels:@[ @"Amsterdam", @"Berlin", @"London" ]
          selectedID:0];
}

- (void)setupInitialCameraPosition {
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
  [super displayExampleWithID:ID on:on];
  switch (ID) {
  case 2:
    [self centerOnLondon];
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
  [self.mapView centerOnCoordinate:[TTCoordinate AMSTERDAM] withZoom:10];
}

- (void)centerOnBerlin {
  [self.mapView centerOnCoordinate:[TTCoordinate BERLIN] withZoom:10];
}

- (void)centerOnLondon {
  [self.mapView centerOnCoordinate:[TTCoordinate LONDON] withZoom:10];
}

@end
