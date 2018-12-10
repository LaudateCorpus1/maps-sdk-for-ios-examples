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

#import "MapMultipleViewController.h"

@interface MapMultipleViewController() <TTMapViewDelegate>
@property (nonatomic,weak) TTMapView* secoundMap;
@end

@implementation MapMultipleViewController

- (void)setupCenterOnWillHappen {
    [self.mapView centerOnCoordinate:TTCoordinate.AMSTERDAM withZoom:12];
}

- (void)setupMap{
    [super setupMap];
    self.mapView.delegate = self;
}

- (void)onMapReady {
    [self setupSecoundMap];
}

- (void)setupSecoundMap {
    TTMapView *map = [[TTMapView alloc] initWithFrame:CGRectZero];
    self.secoundMap = map;
    self.secoundMap.clipsToBounds = true;
    self.secoundMap.layer.borderColor = UIColor.whiteColor.CGColor;
    self.secoundMap.layer.borderWidth = [TTSecoundMap SecoundMapBorderSize];
    NSString *customStyle = [NSBundle.mainBundle pathForResource:@"style" ofType:@"json"];
    [self.secoundMap setStylePath:customStyle];
    [self.mapView addSubview:self.secoundMap];
    [self setupConstrains];
    [self.secoundMap setCameraPosition:[[TTCameraPosition alloc] initWithCamerPosition:TTCoordinate.AMSTERDAM withAnimationDuration:0 withBearing:self.mapView.bearing withPitch:0 withZoom:8]];
    [self drowShapes];
}

#pragma mark TTMapViewDelegate
-(void)mapView:(TTMapView *)mapView didChangedCameraPosition:(TTCameraPosition *)cameraPosition {
    [self updateSecoundMap:cameraPosition.cameraPosition];
}

- (void)updateSecoundMap:(CLLocationCoordinate2D) coordinate{
    if (self.secoundMap != nil){
        [self drowShapes];
        [self.secoundMap setCameraPosition:[[TTCameraPosition alloc] initWithCamerPosition:coordinate withAnimationDuration:0]];
    }
}
         
- (void)drowShapes {
    [self.secoundMap.annotationManager removeAllOverlays];
    CLLocationCoordinate2D coordinates[5];
    coordinates[0] = self.mapView.currentBounds.nwBounds;
    coordinates[1] = CLLocationCoordinate2DMake(self.mapView.currentBounds.nwBounds.latitude, self.mapView.currentBounds.seBounds.longitude);
    coordinates[2] = self.mapView.currentBounds.seBounds;
    coordinates[3] = CLLocationCoordinate2DMake(self.mapView.currentBounds.seBounds.latitude, self.mapView.currentBounds.nwBounds.longitude);
    coordinates[4] = self.mapView.currentBounds.nwBounds;
    
    TTPolyline *polyLine = [TTPolyline polylineWithCoordinates:coordinates count:5 opacity:1 width:1.0  color: [TTColor Yellow]];
    [self.secoundMap.annotationManager addOverlay:polyLine];
}

- (void)setupConstrains {
    CGFloat mapSize = self.mapView.bounds.size.width / 2;
    self.secoundMap.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.secoundMap.heightAnchor constraintEqualToConstant:mapSize] setActive:YES];
    [[self.secoundMap.widthAnchor constraintEqualToConstant:mapSize] setActive:YES];
    [[self.secoundMap.topAnchor constraintEqualToAnchor:self.mapView.topAnchor constant:5] setActive:YES];
    [[self.secoundMap.rightAnchor constraintEqualToAnchor:self.mapView.rightAnchor constant:-5] setActive:YES];
    self.secoundMap.layer.cornerRadius = mapSize/2;
}

@end
