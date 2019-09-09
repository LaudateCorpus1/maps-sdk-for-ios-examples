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

#import "RoutingConsumptionModelViewController.h"
#import <TomTomOnlineSDKRouting/TomTomOnlineSDKRouting.h>

@interface RoutingConsumptionModelViewController () <TTRouteResponseDelegate,
                                                     TTRouteDelegate>
@property(nonatomic, strong) TTRoute *routePlanner;
@property(nonatomic, assign) ETAViewStyle style;
@end

@implementation RoutingConsumptionModelViewController

- (OptionsView *)getOptionsView {
  return [[OptionsViewSingleSelect alloc]
      initWithLabels:@[ @"Combustion", @"Electric" ]
          selectedID:-1];
}

- (void)setupCenterOnWillHappen {
  [self.mapView centerOnCoordinate:[TTCoordinate AMSTERDAM] withZoom:10];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.routePlanner = [TTRoute new];
  self.routePlanner.delegate = self;
  self.mapView.routeManager.delegate = self;
  self.style = ETAViewStyleConsumptionKWh;
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
  [super displayExampleWithID:ID on:on];
  [self.mapView.routeManager removeAllRoutes];
  [self.progress show];
  switch (ID) {
  case 1:
    [self displayElectricRoute];
    break;
  default:
    [self displayCombustionRoute];
    break;
  }
}

#pragma mark Examples

- (void)displayCombustionRoute {
  self.style = ETAViewStyleConsumptionLiters;
  TTSpeedConsumption speedConsumptionInLiters[7];
  speedConsumptionInLiters[0] = TTSpeedConsumptionMake(10, 6.5);
  speedConsumptionInLiters[1] = TTSpeedConsumptionMake(30, 7.0);
  speedConsumptionInLiters[2] = TTSpeedConsumptionMake(50, 8.0);
  speedConsumptionInLiters[3] = TTSpeedConsumptionMake(70, 8.4);
  speedConsumptionInLiters[4] = TTSpeedConsumptionMake(90, 7.7);
  speedConsumptionInLiters[5] = TTSpeedConsumptionMake(120, 7.5);
  speedConsumptionInLiters[6] = TTSpeedConsumptionMake(150, 9.0);
  TTRouteQuery *query = [[[[[[[[[[[[[TTRouteQueryBuilder
      createWithDest:[TTCoordinate UTRECHT]
             andOrig:[TTCoordinate AMSTERDAM]] withMaxAlternatives:2]
      withVehicleWeight:1600] withCurrentFuelInLiters:50.0]
      withCurrentAuxiliaryPowerInLitersPerHour:0.2]
      withFuelEnergyDensityInMJoulesPerLiter:34.2]
      withAccelerationEfficiency:0.33] withDecelerationEfficiency:0.33]
      withUphillEfficiency:0.33] withDownhillEfficiency:0.33]
      withVehicleEngineType:TTOptionVehicleEngineTypeCombustion]
      withSpeedConsumptionInLitersPairs:speedConsumptionInLiters
                                  count:7] build];
  [self.routePlanner planRouteWithQuery:query];
}

- (void)displayElectricRoute {
  self.style = ETAViewStyleConsumptionKWh;
  TTSpeedConsumption speedConsumptionInkWh[6];
  speedConsumptionInkWh[0] = TTSpeedConsumptionMake(10, 5.0);
  speedConsumptionInkWh[1] = TTSpeedConsumptionMake(30, 10.0);
  speedConsumptionInkWh[2] = TTSpeedConsumptionMake(50, 15.0);
  speedConsumptionInkWh[3] = TTSpeedConsumptionMake(70, 20.0);
  speedConsumptionInkWh[4] = TTSpeedConsumptionMake(90, 25.0);
  speedConsumptionInkWh[5] = TTSpeedConsumptionMake(120, 30.0);
  TTRouteQuery *query = [[[[[[[[[[[[[TTRouteQueryBuilder
      createWithDest:[TTCoordinate UTRECHT]
             andOrig:[TTCoordinate AMSTERDAM]] withMaxAlternatives:2]
      withVehicleWeight:1600] withCurrentChargeInkWh:43] withMaxChargeInkWh:85]
      withAuxiliaryPowerInkW:1.7] withAccelerationEfficiency:0.33]
      withDecelerationEfficiency:0.33] withUphillEfficiency:0.33]
      withDownhillEfficiency:0.33]
      withVehicleEngineType:(TTOptionVehicleEngineTypeElectric)]
      withSpeedConsumptionInkWhPairs:speedConsumptionInkWh
                               count:6] build];
  [self.routePlanner planRouteWithQuery:query];
}

#pragma mark TTRouteResponseDelegate

- (void)route:(TTRoute *)route completedWithResult:(TTRouteResult *)result {
  BOOL isActive = YES;
  TTMapRoute *activeRoute;
  for (TTFullRoute *plannedRoute in result.routes) {
    TTMapRoute *mapRoute = [TTMapRoute
        routeWithCoordinatesData:plannedRoute
                  withRouteStyle:isActive ? TTMapRouteStyle.defaultActiveStyle
                                          : TTMapRouteStyle.defaultInactiveStyle
                      imageStart:TTMapRoute.defaultImageDeparture
                        imageEnd:TTMapRoute.defaultImageDestination];
    [self.mapView.routeManager addRoute:mapRoute];
    mapRoute.extraData = plannedRoute.summary;
    if (isActive) {
      activeRoute = mapRoute;
      [self.etaView showWithSummary:plannedRoute.summary
                              style:ETAViewStylePlain];
    }
    isActive = NO;
  }
  [self.mapView.routeManager bringToFrontRoute:activeRoute];
  [self displayRouteOverview];
  [self.progress hide];
}

- (void)route:(TTRoute *)route
    completedWithResponseError:(TTResponseError *)responseError {
  [self handleError:responseError];
}

#pragma mark TTRouteDelegate

- (void)routeClicked:(TTMapRoute *)route {
  for (TTMapRoute *mapRoute in self.mapView.routeManager.routes) {
    [self.mapView.routeManager
        updateRoute:mapRoute
              style:TTMapRouteStyle.defaultInactiveStyle];
  }
  [self.mapView.routeManager updateRoute:route
                                   style:TTMapRouteStyle.defaultActiveStyle];
  [self.etaView showWithSummary:(TTSummary *)route.extraData
                          style:ETAViewStylePlain];
}

@end
