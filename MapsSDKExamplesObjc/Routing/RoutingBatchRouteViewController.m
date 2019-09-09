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

#import "RoutingBatchRouteViewController.h"

typedef NS_ENUM(NSInteger, BatchRouteType) {
  BatchRouteTypeTravelMode,
  BatchRouteTypeRoute,
  BatchRouteTypeAvoids
} BatchRouteSectionType;

@interface RoutingBatchRouteViewController () <
    TTBatchRouteResponseDelegate, TTBatchRouteVisistor, TTRouteDelegate>

@property(nonatomic, strong) TTBatchRoute *batchRoute;
@property NSDictionary *routeDesc;
@property BatchRouteType type;

@end

@implementation RoutingBatchRouteViewController

- (void)setupDict {
  self.routeDesc = @{
    @(BatchRouteTypeTravelMode) :
        @[ @"Travel by Car", @"Travel by Truck", @"Travel by Pedestrian" ],
    @(BatchRouteTypeRoute) :
        @[ @"Fastest route", @"Shortest route", @"Eco route" ],
    @(BatchRouteTypeAvoids) :
        @[ @"Avoid motorways", @"Avoid ferries", @"Avoid toll roads" ]
  };
}

- (OptionsView *)getOptionsView {
  return [[OptionsViewSingleSelect alloc]
      initWithLabels:@[ @"Travel mode", @"Route type", @"Avoids" ]
          selectedID:-1];
}

- (void)setupCenterOnWillHappen {
  [self.mapView centerOnCoordinate:[TTCoordinate AMSTERDAM] withZoom:10];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupDict];
  self.mapView.routeManager.delegate = self;
  self.batchRoute = [TTBatchRoute new];
  self.batchRoute.delegate = self;
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
  [super displayExampleWithID:ID on:on];
  [self.mapView.routeManager removeAllRoutes];
  [self.progress show];
  [self.etaView hide];
  switch (ID) {
  case 2:
    [self performAvoids];
    break;
  case 1:
    [self performRouteType];
    break;
  default:
    [self performTravelMode];
    break;
  }
}

#pragma mark Examples

- (void)performTravelMode {
  self.type = BatchRouteTypeTravelMode;
  TTRouteQuery *queryCar = [[[[[TTRouteQueryBuilder
      createWithDest:[TTCoordinate ROTTERDAM]
             andOrig:[TTCoordinate AMSTERDAM]] withComputeBestOrder:YES]
      withTraffic:YES] withTravelMode:TTOptionTravelModeCar] build];
  TTRouteQuery *queryTruck = [[[[[TTRouteQueryBuilder
      createWithDest:[TTCoordinate ROTTERDAM]
             andOrig:[TTCoordinate AMSTERDAM]] withComputeBestOrder:YES]
      withTraffic:YES] withTravelMode:TTOptionTravelModeTruck] build];
  TTRouteQuery *queryPedestrain = [[[[[TTRouteQueryBuilder
      createWithDest:[TTCoordinate ROTTERDAM]
             andOrig:[TTCoordinate AMSTERDAM]] withComputeBestOrder:YES]
      withTraffic:YES] withTravelMode:TTOptionTravelModePedestrian] build];
  TTBatchRouteQuery *batchQuery =
      [[[[TTBatchRouteQueryBuilder createRouteQuery:queryCar]
          addRouteQuery:queryTruck] addRouteQuery:queryPedestrain] build];

  self.batchRoute = [[TTBatchRoute alloc] init];
  self.batchRoute.delegate = self;
  [self.batchRoute batchRouteWithQuery:batchQuery];
}

- (void)performRouteType {
  self.type = BatchRouteTypeRoute;
  TTRouteQuery *queryFastest = [[[[[TTRouteQueryBuilder
      createWithDest:[TTCoordinate ROTTERDAM]
             andOrig:[TTCoordinate AMSTERDAM]] withComputeBestOrder:YES]
      withTraffic:YES] withRouteType:TTOptionTypeRouteFastest] build];
  TTRouteQuery *queryShortest = [[[[[TTRouteQueryBuilder
      createWithDest:[TTCoordinate ROTTERDAM]
             andOrig:[TTCoordinate AMSTERDAM]] withComputeBestOrder:YES]
      withTraffic:YES] withRouteType:TTOptionTypeRouteShortest] build];
  TTRouteQuery *queryEco = [[[[[TTRouteQueryBuilder
      createWithDest:[TTCoordinate ROTTERDAM]
             andOrig:[TTCoordinate AMSTERDAM]] withComputeBestOrder:YES]
      withTraffic:YES] withRouteType:TTOptionTypeRouteEco] build];

  TTBatchRouteQuery *batchQuery =
      [[[[TTBatchRouteQueryBuilder createRouteQuery:queryFastest]
          addRouteQuery:queryShortest] addRouteQuery:queryEco] build];
  self.batchRoute = [[TTBatchRoute alloc] init];
  self.batchRoute.delegate = self;
  [self.batchRoute batchRouteWithQuery:batchQuery];
}

- (void)performAvoids {
  self.type = BatchRouteTypeAvoids;
  TTRouteQuery *queryMotorways = [[[[[TTRouteQueryBuilder
      createWithDest:[TTCoordinate OSLO]
             andOrig:[TTCoordinate AMSTERDAM]] withComputeBestOrder:YES]
      withTraffic:YES] withAvoidType:TTOptionTypeAvoidMotorways] build];
  TTRouteQuery *queryFerries = [[[[[TTRouteQueryBuilder
      createWithDest:[TTCoordinate OSLO]
             andOrig:[TTCoordinate AMSTERDAM]] withComputeBestOrder:YES]
      withTraffic:YES] withAvoidType:TTOptionTypeAvoidFerries] build];
  TTRouteQuery *queryTollRoads = [[[[[TTRouteQueryBuilder
      createWithDest:[TTCoordinate OSLO]
             andOrig:[TTCoordinate AMSTERDAM]] withComputeBestOrder:YES]
      withTraffic:YES] withAvoidType:TTOptionTypeAvoidTollRoads] build];

  TTBatchRouteQuery *batchQuery =
      [[[[TTBatchRouteQueryBuilder createRouteQuery:queryMotorways]
          addRouteQuery:queryFerries] addRouteQuery:queryTollRoads] build];
  self.batchRoute = [[TTBatchRoute alloc] init];
  self.batchRoute.delegate = self;
  [self.batchRoute batchRouteWithQuery:batchQuery];
}

#pragma mark TTBatchRouteResponseDelegate

- (void)batch:(TTBatchRoute *_Nonnull)route
    completedWithResponse:(TTBatchRouteResponse *_Nonnull)response {
  [self.progress hide];
  [response visit:self];
}

- (void)batch:(TTBatchRoute *_Nonnull)route
    failedWithError:(TTResponseError *_Nonnull)responseError {
  [self handleError:responseError];
}

#pragma mark TTBatchRouteVisistor

- (void)visitRoute:(TTRouteResult *)response {
  TTMapRoute *mapRoute =
      [TTMapRoute routeWithCoordinatesData:response.routes.firstObject
                            withRouteStyle:TTMapRouteStyle.defaultInactiveStyle
                                imageStart:TTMapRoute.defaultImageDeparture
                                  imageEnd:TTMapRoute.defaultImageDestination];
  mapRoute.extraData = response.routes.firstObject.summary;
  [self.mapView.routeManager addRoute:mapRoute];
  [self.progress hide];
  [self.mapView.routeManager showAllRoutesOverview];
}

#pragma mark TTRouteDelegate

- (void)routeClicked:(TTMapRoute *_Nonnull)route {
  NSString *desc;
  for (TTMapRoute *mapRoute in self.mapView.routeManager.routes) {
    [self.mapView.routeManager
        updateRoute:mapRoute
              style:TTMapRouteStyle.defaultInactiveStyle];
  }
  [self.mapView.routeManager updateRoute:route
                                   style:TTMapRouteStyle.defaultActiveStyle];
  [self.mapView.routeManager bringToFrontRoute:route];
  desc = [(NSArray *)[self.routeDesc objectForKey:@(self.type)]
      objectAtIndex:[self.mapView.routeManager.routes indexOfObject:route]];
  [self updateETA:route desc:desc];
}

#pragma Display ETA
- (void)updateETA:(TTMapRoute *)mapRoute desc:(NSString *)desc {
  TTSummary *summary = (TTSummary *)mapRoute.extraData;

  NSDate *eta = summary.arrivalTime;
  NSCalendar *calendar = [NSCalendar currentCalendar];
  [calendar setTimeZone:[NSTimeZone localTimeZone]];
  NSDateComponents *components =
      [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute)
                  fromDate:eta];
  NSString *dateInString =
      [NSString stringWithFormat:@"%02ld:%02ld %@", components.hour,
                                 components.minute, desc];
  [self.etaView updateWithEta:dateInString
               metersDistance:summary.lengthInMetersValue];
}

@end
