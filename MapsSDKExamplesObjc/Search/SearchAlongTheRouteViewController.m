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

#import "SearchAlongTheRouteViewController.h"
#import <TomTomOnlineSDKSearch/TomTomOnlineSDKSearch.h>
#import <TomTomOnlineSDKRouting/TomTomOnlineSDKRouting.h>
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>

@interface SearchAlongTheRouteViewController () <TTRouteResponseDelegate,
                                                 TTAlongRouteSearchDelegate>
@property(nonatomic, strong) TTRoute *routePlanner;
@property(nonatomic, strong) TTAlongRouteSearch *alongRouteSearch;
@property(nonatomic, strong) TTMapRoute *mapRoute;
@end

@implementation SearchAlongTheRouteViewController

- (void)setupInitialCameraPosition {
  if (self.mapView.routeManager.routes.count == 0) {
    [super setupInitialCameraPosition];
  } else {
    [self displayRouteOverview];
  }
}

- (OptionsView *)getOptionsView {
  return [[OptionsViewSingleSelect alloc]
      initWithLabels:@[ @"Car repair", @"Gas stations", @"EV stations" ]
          selectedID:-1];
}

- (void)onMapReady {
  [super onMapReady];
  TTRouteQuery *query =
      [[TTRouteQueryBuilder createWithDest:[TTCoordinate HAARLEM]
                                   andOrig:[TTCoordinate AMSTERDAM]] build];
  [self.routePlanner planRouteWithQuery:query];
  [self.progress show];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.routePlanner = [TTRoute new];
  self.alongRouteSearch = [TTAlongRouteSearch new];
  self.routePlanner.delegate = self;
  self.alongRouteSearch.delegate = self;
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
  [super displayExampleWithID:ID on:on];
  [self.progress show];
  switch (ID) {
  case 2:
    [self searchForEVStations];
    break;
  case 1:
    [self searchForGasStations];
    break;
  default:
    [self searchForCarRepair];
    break;
  }
}

#pragma mark Example

- (void)searchForCarRepair {
  TTAlongRouteSearchQuery *query =
      [[[TTAlongRouteSearchQueryBuilder withTerm:@"REPAIR_FACILITY"
                                       withRoute:self.mapRoute
                               withMaxDetourTime:900] withLimit:10] build];
  [self.alongRouteSearch searchWithQuery:query];
}

- (void)searchForGasStations {
  TTAlongRouteSearchQuery *query =
      [[[TTAlongRouteSearchQueryBuilder withTerm:@"REPAIR_FACILITY"
                                       withRoute:self.mapRoute
                               withMaxDetourTime:900] withLimit:10] build];
  [self.alongRouteSearch searchWithQuery:query];
}

- (void)searchForEVStations {
  TTAlongRouteSearchQuery *query =
      [[[TTAlongRouteSearchQueryBuilder withTerm:@"ELECTRIC_VEHICLE_STATION"
                                       withRoute:self.mapRoute
                               withMaxDetourTime:900] withLimit:10] build];
  [self.alongRouteSearch searchWithQuery:query];
}

#pragma mark TTRouteResponseDelegate

- (void)route:(TTRoute *)route completedWithResult:(TTRouteResult *)result {
  if (!result.routes.firstObject) {
    return;
  }
  self.mapRoute =
      [TTMapRoute routeWithCoordinatesData:result.routes.firstObject
                            withRouteStyle:TTMapRouteStyle.defaultActiveStyle
                                imageStart:TTMapRoute.defaultImageDeparture
                                  imageEnd:TTMapRoute.defaultImageDestination];
  [self.mapView.routeManager addRoute:self.mapRoute];
  [self.mapView.routeManager bringToFrontRoute:self.mapRoute];
  [self displayRouteOverview];
  [self.progress hide];
}

- (void)route:(TTRoute *)route
    completedWithResponseError:(TTResponseError *)responseError {
  [self handleError:responseError];
}

#pragma mark TTAlongRouteSearchDelegate

- (void)search:(TTAlongRouteSearch *)search
    completedWithResponse:(TTAlongRouteSearchResponse *)response {
  [self.progress hide];
  [self.mapView.annotationManager removeAllAnnotations];
  for (TTAlongRouteSearchResult *result in response.results) {
    TTAnnotation *annotation =
        [TTAnnotation annotationWithCoordinate:result.position];
    annotation.selectable = YES;
    [self.mapView.annotationManager addAnnotation:annotation];
  }
}

- (void)search:(TTAlongRouteSearch *)search
    failedWithError:(TTResponseError *)error {
  [self handleError:error];
}

@end
