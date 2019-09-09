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

#import "MapVectorTrafficViewController.h"

@implementation MapVectorTrafficViewController

- (void)setupCenterOnWillHappen {
  [self.mapView centerOnCoordinate:[TTCoordinate LONDON] withZoom:12];
}

- (OptionsView *)getOptionsView {
  return [[OptionsViewMultiSelectWithReset alloc]
      initWithLabels:@[ @"Incidents", @"Flow", @"No traffic" ]
          selectedID:2];
}

- (void)setupMap {
  [super setupMap];
  [self.mapView setTilesType:TTMapTilesVector];
  self.mapView.trafficTileStyle =
      [TTVectorTileType setStyle:TTVectorStyleRelative];
  self.mapView.trafficIncidentsStyle = TTTrafficIncidentsStyleVector;
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
  self.mapView.trafficIncidentsOn = YES;
}

- (void)hideIncidents {
  self.mapView.trafficIncidentsOn = NO;
}

- (void)displayFlow {
  self.mapView.trafficFlowOn = YES;
}

- (void)hideFlow {
  self.mapView.trafficFlowOn = NO;
}

@end
