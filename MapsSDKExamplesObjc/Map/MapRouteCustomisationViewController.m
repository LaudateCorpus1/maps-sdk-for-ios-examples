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

#import "MapRouteCustomisationViewController.h"
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>
#import <TomTomOnlineSDKRouting/TomTomOnlineSDKRouting.h>

@interface MapRouteCustomisationViewController() <TTRouteResponseDelegate>
@property (nonatomic) TTRoute *routePlanner;
@property (nonatomic) TTMapRouteStyle* routeStyle;
@property (nonatomic) UIImage* iconStart;
@property (nonatomic) UIImage* iconEnd;
@end

@implementation MapRouteCustomisationViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[@"Basic", @"Custom"] selectedID:-1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.routePlanner = [TTRoute new];
    self.routePlanner.delegate = self;
    self.routeStyle = [[TTMapRouteStyleBuilder new] build];
    self.iconStart = TTMapRoute.defaultImageDeparture;
    self.iconEnd = TTMapRoute.defaultImageDestination;
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    [self.mapView.routeManager removeAllRoutes];
    [self.progress show];
    switch (ID) {
        case 1:
            [self displayCustomRoute];
            break;
        default:
            [self displayBasicRoute];
            break;
    }
}

#pragma mark Examples

- (void)displayBasicRoute {
    self.routeStyle = TTMapRouteStyle.defaultActiveStyle;
    self.iconStart = TTMapRoute.defaultImageDeparture;
    self.iconEnd = TTMapRoute.defaultImageDestination;
    [self planRoute];
}

- (void)displayCustomRoute {
    self.routeStyle = [[[[[TTMapRouteStyleBuilder new]
                          withWidth:2.0]
                         withFillColor:UIColor.blackColor]
                        withOutlineColor:UIColor.redColor]
                       build];
    self.iconStart = [UIImage imageNamed:@"Start"];
    self.iconEnd = [UIImage imageNamed:@"End"];
    [self planRoute];
}

- (void)planRoute {
    TTRouteQuery *query = [[[TTRouteQueryBuilder createWithDest:[TTCoordinate AMSTERDAM] andOrig:[TTCoordinate ROTTERDAM]]
                            withTravelMode:TTOptionTravelModeCar]
                           build];
    [self.routePlanner planRouteWithQuery:query];
}

#pragma mark TTRouteResponseDelegate
- (void)route:(TTRoute *)route completedWithResult:(TTRouteResult *)result {
    TTFullRoute *plannedRoute = result.routes.firstObject;
    if(!plannedRoute) {
        return;
    }
    TTMapRoute *mapRoute = [TTMapRoute routeWithCoordinatesData:plannedRoute withRouteStyle:self.routeStyle imageStart:self.iconStart imageEnd:self.iconEnd];
    [self.mapView.routeManager addRoute:mapRoute];
    [self.etaView showWithSummary:plannedRoute.summary style:ETAViewStylePlain];
    [self displayRouteOverview];
    [self.progress hide];
}

- (void)route:(TTRoute *)route completedWithResponseError:(TTResponseError *)responseError {
    [self handleError:responseError];
}

@end
