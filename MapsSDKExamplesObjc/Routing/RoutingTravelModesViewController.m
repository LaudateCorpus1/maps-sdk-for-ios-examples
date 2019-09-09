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

#import "RoutingTravelModesViewController.h"
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>
#import <TomTomOnlineSDKRouting/TomTomOnlineSDKRouting.h>

@interface RoutingTravelModesViewController () <TTRouteResponseDelegate>
@property(nonatomic, strong) TTRoute *routePlanner;
@property(nonatomic, strong) TTMapRouteStyle *routeStyle;
@end

@implementation RoutingTravelModesViewController

- (OptionsView *)getOptionsView {
  return [[OptionsViewSingleSelect alloc]
      initWithLabels:@[ @"Car", @"Truck", @"Pedestrian" ]
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
    [self displayPedestrianRoute];
    break;
  case 1:
    [self displayTruckRoute];
    break;
  default:
    [self displayCarRoute];
    break;
  }
}

#pragma mark Examples

- (void)displayCarRoute {
  self.routeStyle = TTMapRouteStyle.defaultActiveStyle;
  TTRouteQuery *query =
      [[[TTRouteQueryBuilder createWithDest:[TTCoordinate AMSTERDAM]
                                    andOrig:[TTCoordinate ROTTERDAM]]
          withTravelMode:TTOptionTravelModeCar] build];
  [self.routePlanner planRouteWithQuery:query];
}

- (void)displayTruckRoute {
  self.routeStyle = TTMapRouteStyle.defaultActiveStyle;
  TTRouteQuery *query =
      [[[TTRouteQueryBuilder createWithDest:[TTCoordinate AMSTERDAM]
                                    andOrig:[TTCoordinate ROTTERDAM]]
          withTravelMode:TTOptionTravelModeTruck] build];
  [self.routePlanner planRouteWithQuery:query];
}

- (void)displayPedestrianRoute {
  NSMutableArray *dashArray = [[NSMutableArray alloc] init];
  [dashArray addObject:[NSNumber numberWithDouble:0.01]];
  [dashArray addObject:[NSNumber numberWithDouble:2.0]];
  self.routeStyle =
      [[[[[[TTMapRouteStyleBuilder new] withLineCapType:TTLineCapTypeRound]
          withWidth:0.3] withFillColor:[TTColor BlueLight]]
          withDashArray:dashArray] build];

  TTRouteQuery *query =
      [[[TTRouteQueryBuilder createWithDest:[TTCoordinate HAARLEMDC]
                                    andOrig:[TTCoordinate HAARLEMZW]]
          withTravelMode:TTOptionTravelModePedestrian] build];
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
                            withRouteStyle:self.routeStyle
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
