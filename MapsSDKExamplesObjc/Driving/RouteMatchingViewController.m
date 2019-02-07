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

#import "RouteMatchingViewController.h"
#import <TomTomOnlineSDKMapsDriving/TomTomOnlineSDKMapsDriving.h>

@interface RouteMatchingViewController () <TTAnnotationDelegate, TTMapViewDelegate, TTMatcherDelegate>

@property (nonatomic, strong) DrivingSource *source;
@property (nonatomic, strong) TTMatcher *matcher;
@property (nonatomic, assign) BOOL startSending;

@property (nonatomic, strong) TTChevronObject *chevron;
@property (nonatomic, strong) TTMapRoute *route;
@property (nonatomic, strong) TTRoute *routePlanner;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic) CLLocationCoordinate2D *waypoints;

@end

@implementation RouteMatchingViewController

- (void)onMapReady {
    self.mapView.annotationManager.delegate = self;
    [self createChevron];
    [self createRoutePlanner];
    [self createRoute];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
}

- (void)createRoutePlanner {
    _routePlanner = [[TTRoute alloc] init];
    self.waypoints = malloc(sizeof(CLLocationCoordinate2D) * 3);
    self.waypoints[0] = [TTCoordinate LODZ_SREBRZYNSKA_WAYPOINT_A];
    self.waypoints[1] = [TTCoordinate LODZ_SREBRZYNSKA_WAYPOINT_B];
    self.waypoints[2] = [TTCoordinate LODZ_SREBRZYNSKA_WAYPOINT_C];
}

- (void)createChevron {
    [self.mapView setShowsUserLocation:false];
    self.chevron = [[TTChevronObject alloc] initNormalImage:[TTChevronObject defaultNormalImage] withNormalImageName:@"active" withDimmedImage:[TTChevronObject defaultDimmedImage] withDimmedImageName:@"inactive"];
}

- (void)createRoute {
    TTRouteQuery *query = [[[TTRouteQueryBuilder createWithDest:TTCoordinate.LODZ_SREBRZYNSKA_STOP andOrig:TTCoordinate.LODZ_SREBRZYNSKA_START] withWayPoints:self.waypoints count:3] build];
    [_routePlanner planRouteWithQuery:query completionHandler:^(TTRouteResult * _Nullable routeResult, TTResponseError * _Nullable error) {
        TTFullRoute *plannedRoute = routeResult.routes.firstObject;
        if (plannedRoute != nil) {
            [self displayPlannedRoute:plannedRoute];
            self.matcher = [[TTMatcher alloc] initWithMatchDataSet:plannedRoute];
            self.matcher.delegate = self;
            [self start];
            [self sendingLocation:plannedRoute];
        }
    }];
}

-(void)displayPlannedRoute:(TTFullRoute*)plannedRoute {
    self.route = [TTMapRoute routeWithCoordinatesData:plannedRoute];
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [self.mapView.routeManager addRoute:self.route];
        [self.mapView.routeManager updateRoute:self.route style:TTMapRouteStyle.defaultActiveStyle];
        [self.mapView.routeManager bringToFrontRoute:self.route];
    }];
}

- (void)start {
    [self.mapView.trackingManager addTrackingObject:self.chevron];
    [self.mapView.trackingManager startTrackingObject:self.chevron];
    self.source = [[DrivingSource alloc] initWithTrackingManager:self.mapView.trackingManager trackingObject:self.chevron];
    [self.source activate];

    TTCameraPosition *camera = [[TTCameraPosition alloc] initWithCamerPosition:[TTCoordinate LODZ_SREBRZYNSKA_START]
                                                         withAnimationDuration:[TTCamera ANIMATION_TIME]
                                                                   withBearing:[TTCamera BEARING_START]
                                                                     withPitch:[TTCamera DEFAULT_MAP_PITCH_FLAT]
                                                                      withZoom:17];
    [self.mapView setCameraPosition:camera];
}

- (void)matcher:(ProviderLocation *)providerLocation {
    TTMatcherLocation *location = [[TTMatcherLocation alloc] initWithCoordinate:providerLocation.coordinate withBearing:providerLocation.bearing withBearingValid:YES withEPE:0.0 withSpeed:providerLocation.speed withDuration:providerLocation.timestamp];
    [self.matcher setMatcherLocation:location];
}

- (void)matcherResultMatchedLocation:(TTMatcherLocation *)matched withOriginalLocation:(TTMatcherLocation *)original isMatched:(BOOL)isMatched {

    [self drawRedCircle:original.coordinate];
    TTLocation *location = [[TTLocation alloc] initWithCoordinate:matched.coordinate withRadius:matched.radius withBearing:matched.bearing withAccuracy:0.0 isDimmed:!isMatched];
    [self.source updateLocationWithLocation: location];
}

- (void)sendingLocation:(TTFullRoute *)fullRoute {

    __block int index = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:true block:^(NSTimer * _Nonnull timer) {
        index++;

        if (index == fullRoute.coordinatesData.count) {
            index = 0;
        }

        if (index - 1 < 0) {
            return;
        }

        CLLocationCoordinate2D prevCoordiante = [LocationUtils coordinateForValueWithValue:[fullRoute.coordinatesData objectAtIndex:(index - 1)]];

        CLLocationCoordinate2D nextCoordinate = [LocationUtils coordinateForValueWithValue:[fullRoute.coordinatesData objectAtIndex:index]];

        double bearing = [LocationUtils bearingWithCoordinateWithCoordinate:nextCoordinate prevCoordianate:prevCoordiante];

        nextCoordinate = [RandomizeCoordinate interpolateWithCoordinate:nextCoordinate];

        ProviderLocation *providerLocation = [[ProviderLocation alloc] initWithCoordinate:nextCoordinate withRadius:0.0 withBearing:bearing withAccuracy:0.0 isDimmed:YES];
        providerLocation.timestamp = [NSDate new].timeIntervalSince1970;
        providerLocation.speed = 5.0;

        [self matcher:providerLocation];
    }];
}

- (void)drawRedCircle:(CLLocationCoordinate2D)coordinate {
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [self.mapView.annotationManager removeAllOverlays];
        TTCircle *circle = [TTCircle circleWithCenterCoordinate:coordinate radius:2 width:1 color:[UIColor redColor] fill:YES colorOutlet:[UIColor redColor]];
        [self.mapView.annotationManager addOverlay:circle];
    }];
}

@end
