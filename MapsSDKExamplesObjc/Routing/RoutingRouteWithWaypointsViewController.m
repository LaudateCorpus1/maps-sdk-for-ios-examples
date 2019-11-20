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

#import "RoutingRouteWithWaypointsViewController.h"

@interface RoutingRouteWithWaypointsViewController () <TTRouteResponseDelegate>
@property(nonatomic, strong) TTRoute *routePlanner;
@property(nonatomic) CLLocationCoordinate2D *waypoints;
@end

@implementation RoutingRouteWithWaypointsViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"Initial order", @"Best order", @"No waypoints" ] selectedID:-1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.routePlanner = [TTRoute new];
    self.routePlanner.delegate = self;
    self.waypoints = malloc(sizeof(CLLocationCoordinate2D) * 3);
    self.waypoints[0] = [TTCoordinate HAMBURG];
    self.waypoints[1] = [TTCoordinate ZURICH];
    self.waypoints[2] = [TTCoordinate BRUSSELS];
    for (int i = 0; i < 3; i++) {
        [self.mapView.annotationManager addAnnotation:[TTAnnotation annotationWithCoordinate:self.waypoints[i]]];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    free(self.waypoints);
    [super viewDidDisappear:animated];
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    [self.mapView.routeManager removeAllRoutes];
    [self.progress show];
    switch (ID) {
    case 2:
        [self displayNoWaypointsRoute];
        break;
    case 1:
        [self displayBestOrderRoute];
        break;
    default:
        [self displayInitialOrderRoute];
        break;
    }
}

#pragma mark Examples

- (void)displayInitialOrderRoute {
    TTRouteQuery *query = [[[TTRouteQueryBuilder createWithDest:[TTCoordinate BERLIN] andOrig:[TTCoordinate AMSTERDAM]] withWayPoints:self.waypoints count:3] build];
    [self.routePlanner planRouteWithQuery:query];
}

- (void)displayBestOrderRoute {
    TTRouteQuery *query = [[[[TTRouteQueryBuilder createWithDest:[TTCoordinate BERLIN] andOrig:[TTCoordinate AMSTERDAM]] withWayPoints:self.waypoints count:3] withComputeBestOrder:YES] build];
    [self.routePlanner planRouteWithQuery:query];
}

- (void)displayNoWaypointsRoute {
    TTRouteQuery *query = [[TTRouteQueryBuilder createWithDest:[TTCoordinate BERLIN] andOrig:[TTCoordinate AMSTERDAM]] build];
    [self.routePlanner planRouteWithQuery:query];
}

#pragma mark TTRouteResponseDelegate

- (void)route:(TTRoute *)route completedWithResult:(TTRouteResult *)result {
    TTFullRoute *plannedRoute = result.routes.firstObject;
    if (!plannedRoute) {
        return;
    }
    TTMapRoute *mapRoute = [TTMapRoute routeWithCoordinatesData:result.routes.firstObject withRouteStyle:TTMapRouteStyle.defaultActiveStyle imageStart:TTMapRoute.defaultImageDeparture imageEnd:TTMapRoute.defaultImageDestination];
    [self.mapView.routeManager addRoute:mapRoute];
    [self.mapView.routeManager bringToFrontRoute:mapRoute];
    [self.etaView showWithSummary:plannedRoute.summary style:ETAViewStylePlain];
    [self displayRouteOverview];
    [self.progress hide];
}

- (void)route:(TTRoute *)route completedWithResponseError:(TTResponseError *)responseError {
    [self handleError:responseError];
}

@end
