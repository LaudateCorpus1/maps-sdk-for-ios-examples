/**
 * Copyright (c) 2021 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its
 * subsidiaries and may be used for internal evaluation purposes or commercial
 * use strictly subject to separate licensee agreement between you and TomTom.
 * If you are the licensee, you are only permitted to use this Software in
 * accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and
 * should immediately return it to TomTom N.V.
 */

#import "ZoomingTheRouteViewController.h"
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>

#define ZOOM_CHANGE_ANIMATION_MILLIS 300
#define SMALL_SPEED_ZOOM_LEVEL 19.0
#define MEDIUM_SPEED_ZOOM_LEVEL 18.0
#define GREATER_SPEED_ZOOM_LEVEL 17.0
#define BIG_SPEED_ZOOM_LEVEL 16.0
#define HUGE_SPEED_ZOOM_LEVEL 14.0
#define SMALL_SPEED_RANGE_END_IN_KMH 10.0
#define MEDIUM_SPEED_RANGE_END_IN_KMH 20.0
#define GREATER_SPEED_RANGE_END_IN_KMH 40.0
#define BIG_SPEED_RANGE_END_IN_KMH 70.0
#define HUGE_SPEED_RANGE_END_IN_KMH 120.0

@interface ZoomingTheRouteViewController () <TTRouteResponseDelegate, LocationManagerMockDelegate>

@property(nonatomic, strong) TTChevronObject *chevron;
@property(nonatomic, strong) TTRoute *routePlanner;

@property(nonatomic, strong) LocationManagerMock *source;
@property(nonatomic, assign) BOOL updateZoom;
@property(nonatomic) CLLocationCoordinate2D *waypoints;

@end

@implementation ZoomingTheRouteViewController

- (void)setupInitialCameraPosition {
    [self.mapView centerOnCoordinate:TTCoordinate.LODZ withZoom:10];
}

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"Start tracking", @"Stop tracking" ] selectedID:-1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _routePlanner = [[TTRoute alloc] initWithKey:Key.Routing];
    self.waypoints = malloc(sizeof(CLLocationCoordinate2D) * 3);
    self.waypoints[0] = [TTCoordinate LODZ_SREBRZYNSKA_WAYPOINT_A];
    self.waypoints[1] = [TTCoordinate LODZ_SREBRZYNSKA_WAYPOINT_B];
    self.waypoints[2] = [TTCoordinate LODZ_SREBRZYNSKA_WAYPOINT_C];
    self.routePlanner.delegate = self;
    self.mapView.contentInset = TTCamera.MAP_DEFAULT_INSETS;
    [self.progress show];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.source deactivate];
    free(self.waypoints);
    [super viewWillDisappear:animated];
}

- (void)onMapReady {
    [super onMapReady];
    [self createRoute];
}

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    switch (ID) {
    case 1:
        [self stop];
        break;
    default:
        [self start];
        break;
    }
}

- (void)createRoute {
    TTRouteQuery *query = [[[TTRouteQueryBuilder createWithDest:TTCoordinate.LODZ_SREBRZYNSKA_STOP andOrig:TTCoordinate.LODZ_SREBRZYNSKA_START] withWayPoints:self.waypoints count:3] build];
    [self.routePlanner planRouteWithQuery:query];
}

- (void)createChevron {
    [self.mapView setShowsUserLocation:false];
    TTChevronAnimationOptions *animation = [[TTChevronAnimationOptionsBuilder createWithAnimatedCornerRounding:true] build];
    self.chevron = [[TTChevronObject alloc] initWithNormalImage:[TTChevronObject defaultNormalImage] withDimmedImage:[TTChevronObject defaultDimmedImage] withChevronAnimationOptions:animation];
}

- (void)start {
    self.updateZoom = YES;
    self.chevron.hidden = NO;
    TTCameraPosition *camera = [[[[[[TTCameraPositionBuilder createWithCameraPosition:[TTCoordinate LODZ_SREBRZYNSKA_START]] withAnimationDuration:[TTCamera ANIMATION_TIME]] withBearing:[TTCamera BEARING_START]] withPitch:[TTCamera DEFAULT_MAP_PITCH_LEVEL_FOR_DRIVING]]
        withZoom:[TTCamera DEFAULT_MAP_ZOOM_LEVEL_FOR_DRIVING]] build];

    [self.mapView setCameraPosition:camera];

    if (!self.chevron) {
        return;
    }
    [self.mapView.trackingManager setBearingSmoothingFilter:[TTTrackingManagerDefault bearingSmoothFactor]];
    [self.mapView.trackingManager startTrackingObject:self.chevron];
}

- (void)stop {
    self.updateZoom = NO;
    [self.mapView.trackingManager stopTrackingObject:self.chevron];
    [self displayRouteOverview];
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

    [self createChevron];
    [self.mapView.trackingManager addTrackingObject:self.chevron];
    self.source = [[LocationManagerMock alloc] initWithRoute:mapRoute];
    self.source.delegate = self;
    [self.source activate];
}

- (void)route:(TTRoute *)route completedWithResponseError:(TTResponseError *)responseError {
    [self handleError:responseError];
}

- (void)applyLocation:(CLLocation *)location {
    [self.mapView.trackingManager updateTrackingObject:self.chevron withTTLocation:[[TTLocation alloc] initWithCoordinate:location.coordinate withRadius:location.horizontalAccuracy withBearing:location.course withAccuracy:location.horizontalAccuracy]];
    [self updateZoomLevelBaseOnNewLocation:location];
}

- (void)updateZoomLevelBaseOnNewLocation:(CLLocation *)location {
    if (!_updateZoom) {
        return;
    }
    double zoom;
    if (location.speed < SMALL_SPEED_RANGE_END_IN_KMH) {
        zoom = SMALL_SPEED_ZOOM_LEVEL;
    } else if (location.speed < MEDIUM_SPEED_RANGE_END_IN_KMH) {
        zoom = MEDIUM_SPEED_ZOOM_LEVEL;
    } else if (location.speed < GREATER_SPEED_RANGE_END_IN_KMH) {
        zoom = GREATER_SPEED_ZOOM_LEVEL;
    } else if (location.speed < BIG_SPEED_RANGE_END_IN_KMH) {
        zoom = BIG_SPEED_ZOOM_LEVEL;
    } else {
        zoom = HUGE_SPEED_ZOOM_LEVEL;
    }
    TTCameraPosition *cameraPosition = [[[[TTCameraPositionBuilder createWithCameraPosition:self.mapView.cameraPosition.cameraPosition] withZoom:zoom] withAnimationDuration:ZOOM_CHANGE_ANIMATION_MILLIS] build];
    [self.mapView setCameraPosition:cameraPosition];
}

- (void)didUpdateLocation:(CLLocation *)location {
    [self applyLocation:location];
}
@end
