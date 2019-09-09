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

#import "MapBallonsViewController.h"
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>
@interface MapBallonsViewController () <TTAnnotationDelegate>
@property(nonatomic, strong) TTAnnotation *customAnnotation;
@end
@implementation MapBallonsViewController

- (OptionsView *)getOptionsView {
  return
      [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"Simple", @"Custom" ]
                                           selectedID:-1];
}

- (void)setupMap {
  [super setupMap];
  self.mapView.annotationManager.delegate = self;
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
  [super displayExampleWithID:ID on:on];
  switch (ID) {
  case 1:
    [self displayCustomBallon];
    break;
  default:
    [self displaySimpleBallon];
    break;
  }
}

#pragma mark TTAnnotationDelegate

- (UIView<TTCalloutView> *)annotationManager:(id<TTAnnotationManager>)manager
                   viewForSelectedAnnotation:
                       (TTAnnotation *)selectedAnnotation {
  if (self.customAnnotation && self.customAnnotation == selectedAnnotation) {
    return [[CustomCallout alloc] initWithFrame:CGRectZero];
  } else {
    return [[TTCalloutOutlineView alloc]
        initWithText:[NSString stringWithFormat:@"%f,%f",
                                                selectedAnnotation.coordinate
                                                    .latitude,
                                                selectedAnnotation.coordinate
                                                    .longitude]];
  }
}

- (void)annotationManager:(id<TTAnnotationManager>)annotationManager
       annotationSelected:(TTAnnotation *)annotation {
  // handle annotation selected event
}

#pragma mark Examples

- (void)displaySimpleBallon {
  TTAnnotation *annotation =
      [TTAnnotation annotationWithCoordinate:[TTCoordinate AMSTERDAM]];
  [self.mapView.annotationManager addAnnotation:annotation];
  [self.mapView.annotationManager selectAnnotation:annotation];
}

- (void)displayCustomBallon {
  TTAnnotation *annotation =
      [TTAnnotation annotationWithCoordinate:[TTCoordinate AMSTERDAM]];
  self.customAnnotation = annotation;
  [self.mapView.annotationManager addAnnotation:annotation];
  [self.mapView.annotationManager selectAnnotation:annotation];
}

@end
