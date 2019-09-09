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

#import "RoutingMatrixViewController.h"

@interface RoutingMatrixViewController () <TTMatrixRouteResponseDelegate>
@property(nonatomic, strong) TTMatrixRoute *matrix;
@property(nonatomic, assign) BOOL oneToManySelected;
@end

@implementation RoutingMatrixViewController

- (void)setupCenterOnWillHappen {
  [self.mapView centerOnCoordinate:TTCoordinate.AMSTERDAM_CENTER_LOCATION
                          withZoom:12];
}

- (OptionsView *)getOptionsView {
  return [[OptionsViewSingleSelect alloc]
      initWithLabels:@[ @"One to Many", @"Many to Many" ]
          selectedID:-1];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.matrix = [TTMatrixRoute new];
  self.matrix.delegate = self;
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
  [super displayExampleWithID:ID on:on];
  [self hideMatrixEta];
  [self.mapView.annotationManager removeAllAnnotations];
  [self.mapView.annotationManager removeAllOverlays];
  [self.progress show];
  switch (ID) {
  case 1:
    self.oneToManySelected = NO;
    [self displayManyToMany];
    break;
  default:
    self.oneToManySelected = YES;
    [self displayOneToMany];
    break;
  }
}

#pragma mark Examples

- (void)displayOneToMany {
  TTMatrixRouteQuery *query = [[[[[[TTMatrixRouteQueryBuilder
      createWithOrigin:TTCoordinate.AMSTERDAM_CENTER_LOCATION
       withDestination:TTCoordinate.AMSTERDAM_RESTAURANT_BRIDGES]
      addDestination:TTCoordinate.AMSTERDAM_RESTAURANT_GREETJE]
      addDestination:TTCoordinate.AMSTERDAM_RESTAURANT_LA_RIVE]
      addDestination:TTCoordinate.AMSTERDAM_RESTAURANT_WAGAMAMA]
      addDestination:TTCoordinate.AMSTERDAM_RESTAURANT_ENVY] build];
  [self.matrix matrixRouteWithQuery:query];
}

- (void)displayManyToMany {
  TTMatrixRouteQuery *query =
      [[[[TTMatrixRouteQueryBuilder createWithOrigin:TTCoordinate.PASSENGER_ONE
                                     withDestination:TTCoordinate.TAXI_ONE]
          addOrigin:TTCoordinate.PASSENGER_TWO]
          addDestination:TTCoordinate.TAXI_TWO] build];
  [self.matrix matrixRouteWithQuery:query];
}

#pragma mark TTMatrixRouteResponseDelegate

- (void)matrix:(TTMatrixRoute *)matrix
    completedWithResponse:(TTMatrixRouteResponse *)response {
  if (self.oneToManySelected) {
    [self presentOneToMany:response];
  } else {
    [self presentManyToMany:response];
  }
}

- (void)matrix:(TTMatrixRoute *)matrix
    completedWithResponseError:(TTResponseError *)responseError {
  [self handleError:responseError];
}

- (void)presentOneToMany:(TTMatrixRouteResponse *)response {
  TTAnnotation *annotationOrigin = [TTAnnotation
      annotationWithCoordinate:TTCoordinate.AMSTERDAM_CENTER_LOCATION
               annotationImage:[TTAnnotationImage createPNGWithName:@"Car"]
                        anchor:TTAnnotationAnchorBottom
                          type:TTAnnotationTypeFocal];
  [self.mapView.annotationManager addAnnotation:annotationOrigin];
  __weak RoutingMatrixViewController *weakSelf = self;
  [response.results
      enumerateKeysAndObjectsUsingBlock:^(
          TTMatrixRoutingResultKey *_Nonnull key,
          TTMatrixRouteResult *_Nonnull obj, BOOL *_Nonnull stop) {
        TTAnnotation *annotation =
            [TTAnnotation annotationWithCoordinate:key.destination];
        [weakSelf.mapView.annotationManager addAnnotation:annotation];

        CLLocationCoordinate2D cooridnates[2];
        cooridnates[0] = key.origin;
        cooridnates[1] = key.destination;
        TTPolyline *polyline = [TTPolyline
            polylineWithCoordinates:cooridnates
                              count:2
                            opacity:1
                              width:4
                              color:[weakSelf determineColorWith:key
                                                    withResponse:response]];
        [weakSelf.mapView.annotationManager addOverlay:polyline];
      }];
  [self.progress hide];
  [self showMatrixEta:self.oneToManySelected withMatrixResponse:response];
  [self zoomToAllMarkers];
}

- (void)presentManyToMany:(TTMatrixRouteResponse *)response {
  __weak RoutingMatrixViewController *weakSelf = self;
  [response.results enumerateKeysAndObjectsUsingBlock:^(
                        TTMatrixRoutingResultKey *_Nonnull key,
                        TTMatrixRouteResult *_Nonnull obj,
                        BOOL *_Nonnull stop) {
    TTAnnotation *annotationOrigin = [TTAnnotation
        annotationWithCoordinate:key.origin
                 annotationImage:[TTAnnotationImage createPNGWithName:@"Walk"]
                          anchor:TTAnnotationAnchorBottom
                            type:TTAnnotationTypeFocal];
    [weakSelf.mapView.annotationManager addAnnotation:annotationOrigin];
    TTAnnotation *annotationDestination = [TTAnnotation
        annotationWithCoordinate:key.destination
                 annotationImage:[TTAnnotationImage createPNGWithName:@"Car"]
                          anchor:TTAnnotationAnchorBottom
                            type:TTAnnotationTypeFocal];
    [weakSelf.mapView.annotationManager addAnnotation:annotationDestination];

    CLLocationCoordinate2D cooridnates[2];
    cooridnates[0] = key.origin;
    cooridnates[1] = key.destination;
    TTPolyline *polyline =
        [TTPolyline polylineWithCoordinates:cooridnates
                                      count:2
                                    opacity:1
                                      width:4
                                      color:[self determineColorWith:key
                                                        withResponse:response]];
    [self.mapView.annotationManager addOverlay:polyline];
  }];
  [self.progress hide];
  [self showMatrixEta:self.oneToManySelected withMatrixResponse:response];
  [self zoomToAllMarkers];
}

- (UIColor *)determineColorWith:
                 (TTMatrixRoutingResultKey *)matrixRoutingResultKey
                   withResponse:(TTMatrixRouteResponse *)response {
  TTMatrixRouteResult *result = response.results[matrixRoutingResultKey];
  TTSummary *matrixSummary = result.summary;
  if (!result || !matrixSummary) {
    return TTColor.GreenDark;
  }
  NSDate *currentEta = matrixSummary.arrivalTime;
  NSDate *minEta = currentEta;
  for (TTMatrixRouteResult *result in response.results.allValues) {
    if ([CLLocation locationsEqualsWithFirst:result.origin
                                      second:matrixRoutingResultKey.origin]) {
      TTSummary *summary = result.summary;
      if (summary) {
        if ([summary.arrivalTime compare:minEta] == NSOrderedAscending) {
          minEta = summary.arrivalTime;
        }
      }
    }
  }
  return [currentEta isEqualToDate:minEta] ? TTColor.GreenDark : TTColor.Gray;
}

@end
