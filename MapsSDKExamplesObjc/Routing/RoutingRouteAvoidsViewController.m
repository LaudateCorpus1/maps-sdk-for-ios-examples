/**
 * Copyright (c) 2018 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its subsidiaries and may be used
 * for internal evaluation purposes or commercial use strictly subject to separate licensee
 * agreement between you and TomTom. If you are the licensee, you are only permitted to use
 * this Software in accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and should
 * immediately return it to TomTom N.V.
 */

#import "RoutingRouteAvoidsViewController.h"
#import <TomTomOnlineSDKRouting/TomTomOnlineSDKRouting.h>
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>

@interface RoutingRouteAvoidsViewController() <TTRouteResponseDelegate>
@property (nonatomic, strong) TTRoute *routePlanner;
@end

@implementation RoutingRouteAvoidsViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[@"Motorways", @"Toll roads", @"Ferries"] selectedID:-1];
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
            [self displayAvoidFerriesRoute];
            break;
        case 1:
            [self displayAvoidTollRoadsRoute];
            break;
        default:
            [self displayAvoidMotorwaysRoute];
            break;
    }
}

#pragma mark Examples

- (void)displayAvoidMotorwaysRoute {
    TTRouteQuery *query = [[[TTRouteQueryBuilder createWithDest:[TTCoordinate OSLO] andOrig:[TTCoordinate AMSTERDAM]]
                            withAvoidType:TTOptionTypeAvoidMotorways]
                           build];
    [self.routePlanner planRouteWithQuery:query];
}


- (void)displayAvoidTollRoadsRoute {
    TTRouteQuery *query = [[[TTRouteQueryBuilder createWithDest:[TTCoordinate OSLO] andOrig:[TTCoordinate AMSTERDAM]]
                            withAvoidType:TTOptionTypeAvoidTollRoads]
                           build];
    [self.routePlanner planRouteWithQuery:query];
}

- (void)displayAvoidFerriesRoute {
    TTRouteQuery *query = [[[TTRouteQueryBuilder createWithDest:[TTCoordinate OSLO] andOrig:[TTCoordinate AMSTERDAM]]
                            withAvoidType:TTOptionTypeAvoidFerries]
                           build];
    [self.routePlanner planRouteWithQuery:query];
}

#pragma mark TTRouteResponseDelegate

- (void)route:(TTRoute *)route completedWithResult:(TTRouteResult *)result {
    TTFullRoute *plannedRoute = result.routes.firstObject;
    if(!plannedRoute) {
        return;
    }
    TTMapRoute *mapRoute = [TTMapRoute routeWithCoordinatesData:result.routes.firstObject imageStart:[TTMapRoute defaultImageDeparture] imageEnd:[TTMapRoute defaultImageDestination]];
    [self.mapView.routeManager addRoute:mapRoute];
    mapRoute.active = YES;
    [self.etaView showWithSummary:plannedRoute.summary style:ETAViewStylePlain];
    [self displayRouteOverview];
    [self.progress hide];
}

- (void)route:(TTRoute *)route completedWithResponseError:(TTResponseError *)responseError {
    [self.toast toastWithMessage:[NSString stringWithFormat:@"error %@", responseError.userInfo[@"description"]]];
    [self.progress hide];
    [self.optionsView deselectAll];
}

@end
