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

#import "RoutingAlternativesRouteViewController.h"
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>
#import <TomTomOnlineSDKRouting/TomTomOnlineSDKRouting.h>

@interface RoutingAlternativesRouteViewController () <TTRouteResponseDelegate, TTRouteDelegate>
@property(nonatomic, strong) TTRoute *routePlanner;
@end

@implementation RoutingAlternativesRouteViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"1", @"3", @"5" ] selectedID:-1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.routePlanner = [[TTRoute alloc] initWithKey:Key.Routing];
    self.routePlanner.delegate = self;
    self.mapView.routeManager.delegate = self;
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    [self.mapView.routeManager removeAllRoutes];
    [self.progress show];
    switch (ID) {
    case 2:
        [self displayRouteWith5Alternative];
        break;
    case 1:
        [self displayRouteWith3Alternative];
        break;
    default:
        [self displayRouteWith1Alternative];
        break;
    }
}

#pragma mark Examples

- (void)displayRouteWith1Alternative {
    TTRouteQuery *query = [[[TTRouteQueryBuilder createWithDest:[TTCoordinate AMSTERDAM] andOrig:[TTCoordinate ROTTERDAM]] withMaxAlternatives:1] build];
    [self.routePlanner planRouteWithQuery:query];
}

- (void)displayRouteWith3Alternative {
    TTRouteQuery *query = [[[TTRouteQueryBuilder createWithDest:[TTCoordinate AMSTERDAM] andOrig:[TTCoordinate ROTTERDAM]] withMaxAlternatives:3] build];
    [self.routePlanner planRouteWithQuery:query];
}

- (void)displayRouteWith5Alternative {
    TTRouteQuery *query = [[[TTRouteQueryBuilder createWithDest:[TTCoordinate AMSTERDAM] andOrig:[TTCoordinate ROTTERDAM]] withMaxAlternatives:5] build];
    [self.routePlanner planRouteWithQuery:query];
}

#pragma mark TTRouteResponseDelegate

- (void)route:(TTRoute *)route completedWithResult:(TTRouteResult *)result {
    TTMapRoute *activeRoute;
    for (TTFullRoute *planedRoute in result.routes) {
        if (activeRoute == nil) {
            TTMapRoute *mapRoute = [TTMapRoute routeWithCoordinatesData:planedRoute withRouteStyle:TTMapRouteStyle.defaultActiveStyle imageStart:TTMapRoute.defaultImageDeparture imageEnd:TTMapRoute.defaultImageDestination];
            [self.mapView.routeManager addRoute:mapRoute];
            mapRoute.extraData = planedRoute.summary;
            activeRoute = mapRoute;
            [self.etaView showWithSummary:planedRoute.summary style:ETAViewStylePlain];
        } else {
            TTMapRoute *mapRoute = [TTMapRoute routeWithCoordinatesData:planedRoute withRouteStyle:TTMapRouteStyle.defaultInactiveStyle imageStart:TTMapRoute.defaultImageDeparture imageEnd:TTMapRoute.defaultImageDestination];
            [self.mapView.routeManager addRoute:mapRoute];
            mapRoute.extraData = planedRoute.summary;
        }
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
    [self.mapView.routeManager bringToFrontRoute:route];
    [self.etaView showWithSummary:(TTSummary *)route.extraData style:ETAViewStylePlain];
}

@end
