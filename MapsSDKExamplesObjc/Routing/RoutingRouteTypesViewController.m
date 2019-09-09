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

#import "RoutingRouteTypesViewController.h"

@interface RoutingRouteTypesViewController () <TTRouteResponseDelegate>
@property(nonatomic, strong) TTRoute *routePlanner;
@end

@implementation RoutingRouteTypesViewController

- (OptionsView *)getOptionsView {
  return [[OptionsViewSingleSelect alloc]
      initWithLabels:@[ @"Fastest", @"Shortest", @"Eco" ]
          selectedID:-1];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.routePlanner = [TTRoute new];
  self.routePlanner.delegate = self;
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
  [super displayExampleWithID:ID on:on];
  [self.mapView.routeManager removeAllRoutes];
  [self.progress show];
  switch (ID) {
  case 2:
    [self displayEcoRoute];
    break;
  case 1:
    [self displayShortestRoute];
    break;
  default:
    [self displayFastestRoute];
    break;
  }
}

#pragma mark Examplea

- (void)displayFastestRoute {
  TTRouteQuery *query =
      [[[TTRouteQueryBuilder createWithDest:[TTCoordinate AMSTERDAM]
                                    andOrig:[TTCoordinate ROTTERDAM]]
          withRouteType:TTOptionTypeRouteFastest] build];
  [self.routePlanner planRouteWithQuery:query];
}

- (void)displayShortestRoute {
  TTRouteQuery *query =
      [[[TTRouteQueryBuilder createWithDest:[TTCoordinate AMSTERDAM]
                                    andOrig:[TTCoordinate ROTTERDAM]]
          withRouteType:TTOptionTypeRouteShortest] build];
  [self.routePlanner planRouteWithQuery:query];
}

- (void)displayEcoRoute {
  TTRouteQuery *query =
      [[[TTRouteQueryBuilder createWithDest:[TTCoordinate AMSTERDAM]
                                    andOrig:[TTCoordinate ROTTERDAM]]
          withRouteType:TTOptionTypeRouteEco] build];
  [self.routePlanner planRouteWithQuery:query];
}

#pragma mark TTRouteResponseDelegate

- (void)route:(TTRoute *)route completedWithResult:(TTRouteResult *)result {
  TTFullRoute *plannedRoute = result.routes.firstObject;
  if (!plannedRoute) {
    return;
  }
  TTMapRoute *mapRoute =
      [TTMapRoute routeWithCoordinatesData:result.routes.firstObject
                            withRouteStyle:TTMapRouteStyle.defaultActiveStyle
                                imageStart:TTMapRoute.defaultImageDeparture
                                  imageEnd:TTMapRoute.defaultImageDestination];
  [self.mapView.routeManager addRoute:mapRoute];
  [self.mapView.routeManager bringToFrontRoute:mapRoute];
  [self.etaView showWithSummary:plannedRoute.summary style:ETAViewStylePlain];
  [self displayRouteOverview];
  [self.progress hide];
}

- (void)route:(TTRoute *)route
    completedWithResponseError:(TTResponseError *)responseError {
  [self handleError:responseError];
}

@end
