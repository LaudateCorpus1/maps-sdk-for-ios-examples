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

#import "MapEventsViewController.h"

@interface MapEventsViewController () <TTMapViewDelegate>

@end

@implementation MapEventsViewController

- (void)setupMap {
  [super setupMap];
  self.mapView.delegate = self;
}

- (void)toast:(NSString *)message
    coordinate:(CLLocationCoordinate2D)coordinate {
  [self.toast
      toastWithMessage:[NSString stringWithFormat:@"%@ %.5f %.5f", message,
                                                  coordinate.latitude,
                                                  coordinate.longitude]];
}

#pragma mark TTMapViewDelegate

- (void)mapView:(TTMapView *)mapView
    didDoubleTap:(CLLocationCoordinate2D)coordinate {
  [self toast:@"Double tap" coordinate:coordinate];
}

- (void)mapView:(TTMapView *)mapView
    didSingleTap:(CLLocationCoordinate2D)coordinate {
  [self toast:@"Single tap" coordinate:coordinate];
}

- (void)mapView:(TTMapView *)mapView
    didLongPress:(CLLocationCoordinate2D)coordinate {
  [self toast:@"Long press" coordinate:coordinate];
}

- (void)mapView:(TTMapView *)mapView
     didPanning:(CLLocationCoordinate2D)coordinate
        inState:(TTMapPanningState)state {
  switch (state) {
  case TTMapPanningBegin:
    [self toast:@"Panning started" coordinate:coordinate];
    break;
  case TTMapPanningChanged:
    [self toast:@"Panning" coordinate:coordinate];
    break;
  case TTMapPanningEnd:
    [self toast:@"Panning finished" coordinate:coordinate];
    break;
  default:
    break;
  }
}

@end
