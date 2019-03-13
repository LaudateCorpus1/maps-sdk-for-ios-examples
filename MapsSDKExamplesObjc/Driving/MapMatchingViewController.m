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

#import "MapMatchingViewController.h"
#import <TomTomOnlineSDKMapsDriving/TomTomOnlineSDKMapsDriving.h>

@interface MapMatchingViewController () <TTAnnotationDelegate, TTMapViewDelegate, TTMatcherDelegate>

@property (nonatomic, strong) DrivingSource *source;
@property (nonatomic, strong) TTMatcher *matcher;
@property (nonatomic, strong) TTChevronObject *chevron;
@property (nonatomic, assign) BOOL startSending;

@end

@implementation MapMatchingViewController

- (void)setupCenterOnWillHappen {
    [self.mapView centerOnCoordinate:TTCoordinate.LODZ withZoom:10];
}

- (void)onMapReady {
    self.mapView.annotationManager.delegate = self;
    [self createChevron];
    [self start];

    if (!self.startSending) {
        [[NSOperationQueue new] addOperationWithBlock:^{
            [self sendingLocation];
            self.startSending = true;
        }];
    }
    self.mapView.maxZoom = TTMapZoom.MAX;
    self.mapView.minZoom = TTMapZoom.MIN;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.matcher = [[TTMatcher alloc] initWithMatchDataSet:self.mapView];
    self.matcher.delegate = self;
    [self setupEtaView];
    [self.etaView updateWithText:@"Red circle shows raw GPS position" icon:[UIImage imageNamed:@"info_small"]];
}

- (void)createChevron {
    [self.mapView setShowsUserLocation:false];
    TTChevronAnimationOptions *animation = [[TTChevronAnimationOptionsBuilder createWithAnimatedCornerRounding:true] build];
    self.chevron = [[TTChevronObject alloc] initWithNormalImage:[TTChevronObject defaultNormalImage] withDimmedImage:[TTChevronObject defaultDimmedImage] withChevronAnimationOptions:animation];
}

- (void)start {
    TTCameraPosition *camera = [[[[[[TTCameraPositionBuilder createWithCameraPosition:[TTCoordinate LODZ_SREBRZYNSKA_START]]
                                    withAnimationDuration:[TTCamera ANIMATION_TIME]]
                                   withBearing:[TTCamera BEARING_START]]
                                  withPitch:[TTCamera DEFAULT_MAP_PITCH_FLAT]]
                                 withZoom:18]
                                build];
    
    [self.mapView setCameraPosition:camera];
    [self.mapView.trackingManager addTrackingObject:self.chevron];
    self.source = [[DrivingSource alloc] initWithTrackingManager:self.mapView.trackingManager trackingObject:self.chevron];
    [self.mapView.trackingManager setBearingSmoothingFilter:[TTTrackingManagerDefault bearingSmoothFactor]];
    [self.mapView.trackingManager startTrackingObject:self.chevron];
    [self.source activate];
}

- (void)matcher:(ProviderLocation *)providerLocation {
    TTMatcherLocation *location = [[TTMatcherLocation alloc] initWithCoordinate:providerLocation.coordinate withBearing:providerLocation.bearing withBearingValid:YES withEPE:0.0 withSpeed:providerLocation.speed withDuration:providerLocation.timestamp];
    [self.matcher setMatcherLocation:location];
}

- (void)matcherResultMatchedLocation:(TTMatcherLocation *)matched withOriginalLocation:(TTMatcherLocation *)original isMatched:(BOOL)isMatched {
    [self drawRedCircle:original.coordinate];
    TTLocation *location = [[TTLocation alloc] initWithCoordinate:matched.coordinate withRadius:matched.radius withBearing:matched.bearing withAccuracy:0.0 isDimmed:!isMatched];
    [self.source updateLocationWithLocation: location];
    [self.chevron setHidden:NO];
}

- (void)sendingLocation {
    LocationCSVProvider *locationProvider = [[LocationCSVProvider alloc] initWithCsvFile:@"simple_route"];

    for (ProviderLocation *providerLocation in locationProvider.locations) {
        int index = (int)[locationProvider.locations indexOfObject:providerLocation];
        if ((index - 1) > 0) {
            ProviderLocation *prev = [locationProvider.locations objectAtIndex:(index - 1)];
            ProviderLocation *next = [locationProvider.locations objectAtIndex:index];

            ProviderLocation *location = [[ProviderLocation alloc] initWithCoordinate:next.coordinate withRadius:next.radius withBearing:next.bearing withAccuracy:next.accuracy];
            location.timestamp = next.timestamp;
            location.speed = next.speed;

            [self matcher:location];
            double time = next.timestamp - prev.timestamp;
            sleep(time/1000);
        }
    }
}

- (void)drawRedCircle:(CLLocationCoordinate2D)coordinate {
    [self.mapView.annotationManager removeAllOverlays];
    TTCircle *circle = [TTCircle circleWithCenterCoordinate:coordinate radius:2 width:1 color:[UIColor redColor] fill:YES colorOutlet:[UIColor redColor]];
    [self.mapView.annotationManager addOverlay:circle];
}

@end
