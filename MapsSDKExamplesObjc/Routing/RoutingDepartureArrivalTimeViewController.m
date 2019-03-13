/**
 * Copyright (c) 2019 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its subsidiaries and may be used
 * for internal evaluation purposes or commercial use strictly subject to separate licensee
 * agreement between you and TomTom. If you are the licensee, you are only permitted to use
 * this Software in accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and should
 * immediately return it to TomTom N.V.
 */

#import "RoutingDepartureArrivalTimeViewController.h"
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>
#import <TomTomOnlineSDKRouting/TomTomOnlineSDKRouting.h>

@interface RoutingDepartureArrivalTimeViewController() <TTRouteResponseDelegate>
@property (nonatomic, strong) ActionSheet *actionSheet;
@property (nonatomic, assign) ETAViewStyle etaStyle;
@property (nonatomic, strong) TTRoute *routePlanner;
@end

@implementation RoutingDepartureArrivalTimeViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[@"Departure at", @"Arrival at"] selectedID:-1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.routePlanner = [TTRoute new];
    self.routePlanner.delegate = self;
    self.actionSheet = [[ActionSheet alloc] initWithToast:self.toast viewController:self];
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    switch (ID) {
        case 1:
            [self displayRouteWithArrival];
            break;
        default:
            [self displayRouteWithDeparture];
            break;
    }
}

#pragma mark Examples

- (void)displayRouteWithDeparture {
    self.etaStyle = ETAViewStylePlain;
    RoutingDepartureArrivalTimeViewController * __weak weakSelf = self;
    [self.actionSheet showWithResult:^(NSDate * date) {
        if(date){
            [weakSelf.progress show];
            TTRouteQuery *query = [[[TTRouteQueryBuilder createWithDest:[TTCoordinate ROTTERDAM] andOrig:[TTCoordinate AMSTERDAM]]
                                    withDepartAt:date]
                                   build];
            [weakSelf.routePlanner planRouteWithQuery:query];
        } else {
            [weakSelf.optionsView deselectAll];
        }
    }];
}

- (void)displayRouteWithArrival {
    self.etaStyle = ETAViewStyleArrival;
    RoutingDepartureArrivalTimeViewController * __weak weakSelf = self;
    [self.actionSheet showWithResult:^(NSDate * date) {
        if(date){
            [weakSelf.progress show];
            TTRouteQuery *query = [[[TTRouteQueryBuilder createWithDest:[TTCoordinate ROTTERDAM] andOrig:[TTCoordinate AMSTERDAM]]
                                    withArriveAt:date]
                                   build];
            [weakSelf.routePlanner planRouteWithQuery:query];
        } else {
            [weakSelf.optionsView deselectAll];
        }
    }];
}

#pragma mark TTRouteResponseDelegate

- (void)route:(TTRoute *)route completedWithResult:(TTRouteResult *)result {
    TTFullRoute *plannedRoute = result.routes.firstObject;
    if(!plannedRoute) {
        return;
    }
    TTMapRoute *mapRoute = [TTMapRoute routeWithCoordinatesData:result.routes.firstObject withRouteStyle:TTMapRouteStyle.defaultActiveStyle
                                                     imageStart:TTMapRoute.defaultImageDeparture imageEnd:TTMapRoute.defaultImageDestination];
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
