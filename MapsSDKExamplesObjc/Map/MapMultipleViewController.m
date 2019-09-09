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

#import "MapMultipleViewController.h"

@interface MapMultipleViewController () <TTMapViewDelegate>
@property(nonatomic, weak) TTMapView *secondMap;
@end

@implementation MapMultipleViewController

- (void)setupCenterOnWillHappen {
  [self.mapView centerOnCoordinate:TTCoordinate.AMSTERDAM withZoom:12];
}

- (void)setupMap {
  [super setupMap];
  self.mapView.delegate = self;
}

- (void)onMapReady {
  [super onMapReady];
  [self setupSecondMap];
}

- (void)setupSecondMap {
  TTMapView *map = [[TTMapView alloc] initWithFrame:CGRectZero];
  self.secondMap = map;
  self.secondMap.clipsToBounds = true;
  self.secondMap.layer.borderColor = UIColor.whiteColor.CGColor;
  self.secondMap.layer.borderWidth = [TTSecoundMap SecoundMapBorderSize];
  NSString *customStyle = [NSBundle.mainBundle pathForResource:@"style"
                                                        ofType:@"json"];
  [self.secondMap setStylePath:customStyle];
  [self.mapView addSubview:self.secondMap];
  [self setupConstraints];
  [self.secondMap
      setCameraPosition:[[[[TTCameraPositionBuilder
                            createWithCameraPosition:TTCoordinate.AMSTERDAM]
                            withBearing:self.mapView.bearing] withZoom:8]
                            build]];
  [self drawShapes];
}

#pragma mark TTMapViewDelegate
- (void)mapView:(TTMapView *)mapView
    didChangedCameraPosition:(TTCameraPosition *)cameraPosition {
  [self updateSecoundMap:cameraPosition.cameraPosition];
}

- (void)updateSecoundMap:(CLLocationCoordinate2D)coordinate {
  if (self.secondMap != nil) {
    [self drawShapes];
    [self.secondMap
        setCameraPosition:[[TTCameraPositionBuilder
                              createWithCameraPosition:coordinate] build]];
  }
}

- (void)drawShapes {
  [self.secondMap.annotationManager removeAllOverlays];
  CLLocationCoordinate2D coordinates[5];
  coordinates[0] = self.mapView.currentBounds.nwBounds;
  coordinates[1] =
      CLLocationCoordinate2DMake(self.mapView.currentBounds.nwBounds.latitude,
                                 self.mapView.currentBounds.seBounds.longitude);
  coordinates[2] = self.mapView.currentBounds.seBounds;
  coordinates[3] =
      CLLocationCoordinate2DMake(self.mapView.currentBounds.seBounds.latitude,
                                 self.mapView.currentBounds.nwBounds.longitude);
  coordinates[4] = self.mapView.currentBounds.nwBounds;

  TTPolyline *polyLine = [TTPolyline polylineWithCoordinates:coordinates
                                                       count:5
                                                     opacity:1
                                                       width:1.0
                                                       color:[TTColor Yellow]];
  [self.secondMap.annotationManager addOverlay:polyLine];
}

- (void)setupConstraints {
  CGFloat mapSize = self.mapView.bounds.size.width / 2;
  self.secondMap.translatesAutoresizingMaskIntoConstraints = NO;
  [[self.secondMap.heightAnchor constraintEqualToConstant:mapSize]
      setActive:YES];
  [[self.secondMap.widthAnchor constraintEqualToConstant:mapSize]
      setActive:YES];
  [[self.secondMap.topAnchor constraintEqualToAnchor:self.mapView.topAnchor
                                            constant:5] setActive:YES];
  [[self.secondMap.rightAnchor constraintEqualToAnchor:self.mapView.rightAnchor
                                              constant:-5] setActive:YES];
  self.secondMap.layer.cornerRadius = mapSize / 2;
}

@end
