/**
 * Copyright (c) 2020 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its subsidiaries and may be used
 * for internal evaluation purposes or commercial use strictly subject to separate licensee
 * agreement between you and TomTom. If you are the licensee, you are only permitted to use
 * this Software in accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and should
 * immediately return it to TomTom N.V.
 */

#import "MapInitializationViewController.h"

@interface MapInitializationViewController () <TTMapViewDelegate>

@property TTMapView *map;
@property UIView *placeholderView;

@end

@implementation MapInitializationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"Bounding box", @"Starting point" ] selectedID:0];
}

#pragma mark OptionsViewDelegate

- (void)setupMap {
    [self setupPlaceholderViewConstraint];
    [self mapConfigurationWithBoundingBox];
}

- (void)setupPlaceholderViewConstraint {
    self.placeholderView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.placeholderView];
    self.placeholderView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.placeholderView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0].active = YES;
    [self.placeholderView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0].active = YES;
    [self.placeholderView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:0].active = YES;
    [self.placeholderView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:0].active = YES;
}

- (void)setupMapViewConstraint {
    [self.placeholderView addSubview:self.map];
    self.map.translatesAutoresizingMaskIntoConstraints = NO;
    [self.map.topAnchor constraintEqualToAnchor:self.placeholderView.topAnchor constant:0].active = YES;
    [self.map.bottomAnchor constraintEqualToAnchor:self.placeholderView.bottomAnchor constant:0].active = YES;
    [self.map.leftAnchor constraintEqualToAnchor:self.placeholderView.leftAnchor constant:0].active = YES;
    [self.map.rightAnchor constraintEqualToAnchor:self.placeholderView.rightAnchor constant:0].active = YES;
    self.map.delegate = self;
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    [self.progress show];
    switch (ID) {
    case 1:
        [self mapConfigurationWithStartingPoint];
        break;
    default:
        [self mapConfigurationWithBoundingBox];
        break;
    }
}

#pragma mark Examples

- (void)mapConfigurationWithBoundingBox {
    [self.map removeFromSuperview];
    self.map = NULL;

    NSArray *arrayCoordinates = [NSArray
        arrayWithObjects:[[CLLocation alloc] init:[TTCoordinate AMSTERDAM_BOUNDINGBOX_LT]], [[CLLocation alloc] init:[TTCoordinate AMSTERDAM_BOUNDINGBOX_RT]], [[CLLocation alloc] init:[TTCoordinate AMSTERDAM_BOUNDINGBOX_LB]], [[CLLocation alloc] init:[TTCoordinate AMSTERDAM_BOUNDINGBOX_RB]], nil];
    TTCenterOnGeometry *transform = [[[[TTCenterOnGeometryBuilder createWithGeometry:arrayCoordinates withPadding:UIEdgeInsetsZero] withPitch:30] withBearing:-90] build];
    TTMapConfigurationBuilder *config = [[TTMapConfigurationBuilder createBuilder] withViewportTransform:transform];

    TTLogoPosition *position = [[TTLogoPosition alloc] initWithVerticalPosition:top horizontalPosition:right verticalOffset:35 horizontalOffset:-170];
    [config withTomTomLogoPosition:position];
    self.map = [[TTMapView alloc] initWithFrame:CGRectZero mapConfiguration:[config build]];
    [self setupMapViewConstraint];
}

- (void)mapConfigurationWithStartingPoint {
    [self.map removeFromSuperview];
    self.map = NULL;
    TTCenterOnPoint *transform = [[[TTCenterOnPointBuilder createWithCenter:[TTCoordinate LODZ_ZEROMSKIEGO]] withZoom:15] build];
    TTMapConfigurationBuilder *config = [[TTMapConfigurationBuilder createBuilder] withViewportTransform:transform];
    TTLogoPosition *position = [[TTLogoPosition alloc] initWithVerticalPosition:bottom horizontalPosition:right verticalOffset:-65 horizontalOffset:-170];
    [config withTomTomLogoPosition:position];
    self.map = [[TTMapView alloc] initWithFrame:CGRectZero mapConfiguration:[config build]];
    [self setupMapViewConstraint];
}

- (void)onMapReady:(TTMapView *)mapView {
    [self.progress hide];
}

@end
