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

#import "MapFollowTheChevronController.h"
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>

@interface MapFollowTheChevronController ()

@property (nonatomic, strong) TTChevronObject *chevron;
@property (nonatomic, strong) TTMapRoute *route;
@property (nonatomic, strong) TTRoute *routePlanner;

@property (nonatomic, strong) MapFollowTheChevronSource *source;
@property (nonatomic) CLLocationCoordinate2D *waypoints;


@end

@implementation MapFollowTheChevronController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[@"Start tracking", @"Stop tracking"] selectedID:-1];
}

- (void)onMapReady {
    [super onMapReady];
    _routePlanner = [[TTRoute alloc] init];
    self.waypoints = malloc(sizeof(CLLocationCoordinate2D) * 3);
    self.waypoints[0] = [TTCoordinate LODZ_SREBRZYNSKA_WAYPOINT_A];
    self.waypoints[1] = [TTCoordinate LODZ_SREBRZYNSKA_WAYPOINT_B];
    self.waypoints[2] = [TTCoordinate LODZ_SREBRZYNSKA_WAYPOINT_C];
    [self createRoute];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.source deactivate];
    free(self.waypoints);
    [super viewWillDisappear:animated];
}

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    switch (ID) {
        case 0:
            [self start];
            break;

        default:
            [self stop];
    }
}

- (void)createChevron {
    [self.mapView setShowsUserLocation:false];
    self.chevron = [[TTChevronObject alloc] initNormalImage:[TTChevronObject defaultNormalImage] withNormalImageName:@"active" withDimmedImage:[TTChevronObject defaultDimmedImage] withDimmedImageName:@"inactive"];
}

- (void)createRoute {
    TTRouteQuery *query = [[[TTRouteQueryBuilder createWithDest:TTCoordinate.LODZ_SREBRZYNSKA_STOP andOrig:TTCoordinate.LODZ_SREBRZYNSKA_START] withWayPoints:self.waypoints count:3] build];
    __weak MapFollowTheChevronController *weakSelf = self;
    [_routePlanner planRouteWithQuery:query completionHandler:^(TTRouteResult * _Nullable routeResult, TTResponseError * _Nullable error) {
        TTFullRoute *plannedRoute = routeResult.routes.firstObject;
        if (plannedRoute != nil) {
            [weakSelf displayPlannedRoute:plannedRoute];
            [weakSelf createChevron];
            [weakSelf.mapView.trackingManager addTrackingObject:self.chevron];
            weakSelf.source = [[MapFollowTheChevronSource alloc] initWithTrackingManager:self.mapView.trackingManager trackingObject:self.chevron route:self.route];
            [weakSelf.source activate];
            
        }
    }];
}

- (void)displayPlannedRoute:(TTFullRoute *)plannedRoute {
    self.route = [TTMapRoute routeWithCoordinatesData:plannedRoute withRouteStyle:TTMapRouteStyle.defaultActiveStyle
                                           imageStart:TTMapRoute.defaultImageDeparture imageEnd:TTMapRoute.defaultImageDestination];
    __weak MapFollowTheChevronController *weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [weakSelf.mapView.routeManager addRoute:self.route];
        [weakSelf.mapView.routeManager showRouteOverview:self.route];
        [weakSelf.mapView.routeManager bringToFrontRoute:self.route];
        [weakSelf showRoute];
    }];
}

- (void)start {
    TTCameraPosition *camera = [[TTCameraPosition alloc] initWithCamerPosition:[TTCoordinate LODZ_SREBRZYNSKA_START]
                                                         withAnimationDuration:[TTCamera ANIMATION_TIME]
                                                                   withBearing:[TTCamera BEARING_START]
                                                                     withPitch:[TTCamera DEFAULT_MAP_PITCH_LEVEL_FOR_DRIVING]
                                                                      withZoom:[TTCamera DEFAULT_MAP_ZOOM_LEVEL_FOR_DRIVING]];
    [self.mapView setCameraPosition:camera];
    
    
    if (self.chevron != nil){
    [self.mapView.trackingManager startTrackingObject:self.chevron];
    }
}

- (void)stop {
    [self.mapView.trackingManager stopTrackingObject:self.chevron];

    [self showRoute];
}

- (void)showRoute {
    if (self.route) {
        self.mapView.contentInset = TTCamera.MAP_DEFAULT_INSETS;
        [self.mapView.routeManager showRouteOverview:self.route];
    }
}


@end
