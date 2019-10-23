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

#import "MapMarkersClusteringViewController.h"

@implementation MapMarkersClusteringViewController

- (void)setupInitialCameraPosition {
}

- (void)onMapReady {
  [super onMapReady];
  [self.mapView zoomToAllAnnotations];
}

- (void)setupMap {
  [super setupMap];
  self.mapView.annotationManager.clustering = YES;
  [self addRandomMarkers];
}

- (void)addRandomMarkers {
  for (int i = 0; i < 90; i++) {
    CLLocationCoordinate2D coordinate = [CLLocation
        makeRandomCoordinateForCenteroidWithCenter:[TTCoordinate AMSTERDAM]];
    TTAnnotation *annotation =
        [TTAnnotation annotationWithCoordinate:coordinate];
    annotation.shouldCluster = YES;
    [self.mapView.annotationManager addAnnotation:annotation];
  }
  for (int i = 0; i < 150; i++) {
    CLLocationCoordinate2D coordinate = [CLLocation
        makeRandomCoordinateForCenteroidWithCenter:[TTCoordinate ROTTERDAM]];
    TTAnnotation *annotation =
        [TTAnnotation annotationWithCoordinate:coordinate];
    annotation.shouldCluster = YES;
    [self.mapView.annotationManager addAnnotation:annotation];
  }
}

@end
