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

#import "RoutingSupportingPointsViewController.h"

@interface RoutingSupportingPointsViewController () <TTRouteResponseDelegate, TTRouteDelegate>
@property(nonatomic, strong) TTRoute *routePlanner;
@property(nonatomic) CLLocationCoordinate2D *suporrtingPoints;
@end

@implementation RoutingSupportingPointsViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"0 m", @"10 km" ] selectedID:-1];
}

- (void)setupInitialCameraPosition {
    [self.mapView centerOnCoordinate:[TTCoordinate PORTUGAL_NOVA] withZoom:10];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.routePlanner = [TTRoute new];
    self.routePlanner.delegate = self;
    self.mapView.routeManager.delegate = self;
    self.suporrtingPoints = malloc(sizeof(CLLocationCoordinate2D) * 5);
    self.suporrtingPoints[0] = CLLocationCoordinate2DMake(40.10995732392718, -8.501433134078981);
    self.suporrtingPoints[1] = CLLocationCoordinate2DMake(40.11115121590874, -8.500000834465029);
    self.suporrtingPoints[2] = CLLocationCoordinate2DMake(40.11089684892725, -8.497683405876161);
    self.suporrtingPoints[3] = CLLocationCoordinate2DMake(40.11192251642396, -8.498423695564272);
    self.suporrtingPoints[4] = CLLocationCoordinate2DMake(40.209408, -8.423741);
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    [self.mapView.routeManager removeAllRoutes];
    [self.progress show];
    switch (ID) {
    case 1:
        [self displayDeviation10kmRoute];
        break;
    default:
        [self displayDeviation0mRoute];
        break;
    }
}

#pragma mark Examples

- (void)displayDeviation0mRoute {
    TTRouteQuery *query = [[[[[[TTRouteQueryBuilder createWithDest:[TTCoordinate PORTUGAL_COIMBRA] andOrig:[TTCoordinate PORTUGAL_NOVA]] withMaxAlternatives:1] withMinDeviationTime:0] withSupportingPoints:self.suporrtingPoints count:5] withMinDeviationDistance:0] build];
    [self.routePlanner planRouteWithQuery:query];
}

- (void)displayDeviation10kmRoute {
    TTRouteQuery *query = [[[[[[TTRouteQueryBuilder createWithDest:[TTCoordinate PORTUGAL_COIMBRA] andOrig:[TTCoordinate PORTUGAL_NOVA]] withMaxAlternatives:1] withMinDeviationTime:0] withSupportingPoints:self.suporrtingPoints count:5] withMinDeviationDistance:10000] build];
    [self.routePlanner planRouteWithQuery:query];
}

#pragma mark TTRouteResponseDelegate

- (void)route:(TTRoute *)route completedWithResult:(TTRouteResult *)result {
    BOOL isActive = YES;
    TTMapRoute *activeRoute;
    for (TTFullRoute *plannedRoute in result.routes) {
        TTMapRoute *mapRoute = [TTMapRoute routeWithCoordinatesData:plannedRoute withRouteStyle:isActive ? TTMapRouteStyle.defaultActiveStyle : TTMapRouteStyle.defaultInactiveStyle imageStart:TTMapRoute.defaultImageDeparture imageEnd:TTMapRoute.defaultImageDestination];
        [self.mapView.routeManager addRoute:mapRoute];
        mapRoute.extraData = plannedRoute.summary;
        if (isActive) {
            activeRoute = mapRoute;
            [self.etaView showWithSummary:plannedRoute.summary style:ETAViewStylePlain];
        }
        isActive = NO;
    }
    [self.mapView.routeManager bringToFrontRoute:activeRoute];
    [self displayRouteOverview];
    [self.progress hide];
}

- (void)route:(TTRoute *)route completedWithResponseError:(TTResponseError *)responseError {
    [self handleError:responseError];
}

#pragma mark TTRouteDelegate

- (void)routeClicked:(TTMapRoute *)route {
    for (TTMapRoute *mapRoute in self.mapView.routeManager.routes) {
        [self.mapView.routeManager updateRoute:mapRoute style:TTMapRouteStyle.defaultInactiveStyle];
    }
    [self.mapView.routeManager updateRoute:route style:TTMapRouteStyle.defaultActiveStyle];
    [self.etaView showWithSummary:(TTSummary *)route.extraData style:ETAViewStylePlain];
    [self.mapView.routeManager bringToFrontRoute:route];
}

@end
