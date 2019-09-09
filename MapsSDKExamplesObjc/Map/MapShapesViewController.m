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

#import "MapShapesViewController.h"

@interface MapShapesViewController () <TTAnnotationDelegate>

@end

@implementation MapShapesViewController

- (OptionsView *)getOptionsView {
  return [[OptionsViewSingleSelect alloc]
      initWithLabels:@[ @"Polygon", @"Polyline", @"Circle" ]
          selectedID:-1];
}

- (void)setupMap {
  [super setupMap];
  self.mapView.annotationManager.delegate = self;
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
  [super displayExampleWithID:ID on:on];
  [self.mapView.annotationManager removeAllOverlays];
  switch (ID) {
  case 2:
    [self displayCircle];
    break;
  case 1:
    [self displayPolyline];
    break;
  default:
    [self displayPolygon];
    break;
  }
}

#pragma mark Examples

- (void)displayPolygon {
  UIColor *color = [UIColor random];
  NSInteger pointsCount = 24;
  NSArray<NSValue *> *values =
      [CLLocation makeCoordinatesInCenterAreaWithCenter:[TTCoordinate AMSTERDAM]
                                            pointsCount:pointsCount];
  CLLocationCoordinate2D *coordinates = [self convertCoordinates:values];
  TTPolygon *polygon = [TTPolygon polygonWithCoordinates:coordinates
                                                   count:pointsCount
                                                 opacity:1
                                                   color:color
                                            colorOutline:color];
  [self.mapView.annotationManager addOverlay:polygon];
  free(coordinates);
}

- (void)displayPolyline {
  UIColor *color = [UIColor random];
  NSInteger pointsCount = 24;
  NSArray<NSValue *> *values =
      [CLLocation makeCoordinatesInCenterAreaWithCenter:[TTCoordinate AMSTERDAM]
                                            pointsCount:pointsCount];
  CLLocationCoordinate2D *coordinates = [self convertCoordinates:values];
  TTPolyline *polyline = [TTPolyline polylineWithCoordinates:coordinates
                                                       count:pointsCount
                                                     opacity:1
                                                       width:8
                                                       color:color];
  [self.mapView.annotationManager addOverlay:polyline];
  free(coordinates);
}

- (void)displayCircle {
  UIColor *color = [UIColor random];
  TTCircle *circle =
      [TTCircle circleWithCenterCoordinate:[TTCoordinate AMSTERDAM]
                                    radius:5000
                                   opacity:1
                                     width:10
                                     color:color
                                      fill:YES
                               colorOutlet:color];
  [self.mapView.annotationManager addOverlay:circle];
}

#pragma TTAnnotationDelegate
- (void)annotationManager:(id<TTAnnotationManager>)manager
            touchUpCircle:(TTCircle *)circle {
  // called when circle clicked
}

- (void)annotationManager:(id<TTAnnotationManager>)manager
           touchUpPolygon:(TTPolygon *)polygon {
  // called when polygon clicked
}

- (void)annotationManager:(id<TTAnnotationManager>)manager
          touchUpPolyline:(TTPolyline *)polyline {
  // called when polyline clicked
}

- (CLLocationCoordinate2D *)convertCoordinates:
    (NSArray<NSValue *> *)coordinatesValues {
  CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D *)malloc(
      coordinatesValues.count * sizeof(CLLocationCoordinate2D));
  for (NSUInteger i = 0; i < coordinatesValues.count; i++) {
    CLLocationCoordinate2D decoded;
    [coordinatesValues[i] getValue:&decoded];
    coordinates[i] = decoded;
  }
  return coordinates;
}

@end
