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

#import "RoutingReachableRangeViewController.h"
#import <TomTomOnlineSDKRouting/TomTomOnlineSDKRouting.h>
#import "ReachableRangeQueryFactory.h"

@interface RoutingReachableRangeViewController () <TTReachableRangeDelegate>
@property(nonatomic, strong) TTReachableRange *reachabeRange;
@property(nonatomic, strong) ReachableRangeQueryFactory *queryFactory;
@end

@implementation RoutingReachableRangeViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"Combustion", @"Electric", @"Time - 2h" ] selectedID:-1];
}

- (void)setupInitialCameraPosition {
    [self.mapView centerOnCoordinate:[TTCoordinate AMSTERDAM] withZoom:10];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.queryFactory = [ReachableRangeQueryFactory alloc];
    self.reachabeRange = [TTReachableRange new];
    self.reachabeRange.delegate = self;
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    [self.mapView.annotationManager removeAllOverlays];
    [self.progress show];
    switch (ID) {
    case 2:
        [self displayReachableRangeIn2hTime];
        break;
    case 1:
        [self displayReachableRangeForElectric];
        break;
    default:
        [self displayReachableRangeForCombustion];
        break;
    }
}

#pragma mark Examples

- (void)displayReachableRangeForCombustion {
    [self.reachabeRange findReachableRangeWithQuery:[self.queryFactory createReachableRangeQueryForCombustion]];
}

- (void)displayReachableRangeForElectric {
    [self.reachabeRange findReachableRangeWithQuery:[self.queryFactory createReachableRangeQueryForElectric]];
}

- (void)displayReachableRangeIn2hTime {
    [self.reachabeRange findReachableRangeWithQuery:[self.queryFactory createReachableRangeQueryForElectricLimitTo2Hours]];
}

#pragma mark TTReachableRangeDelegate

- (void)reachableRange:(TTReachableRange *)range completedWithResult:(TTReachableRangeResponse *)response {
    [self.progress hide];
    CLLocationCoordinate2D *coordinates = malloc(sizeof(CLLocationCoordinate2D) * response.result.boundriesCount);
    for (NSInteger i = 0; i < response.result.boundriesCount; i++) {
        coordinates[i] = [response.result boundryAt:i];
    }
    TTPolygon *polygon = [TTPolygon polygonWithCoordinates:coordinates count:response.result.boundriesCount opacity:1 color:[TTColor RedSemiTransparent] colorOutline:[TTColor RedSemiTransparent]];
    free(coordinates);
    [self.mapView.annotationManager addOverlay:polygon];
    [self.mapView zoomToCoordinatesData:polygon];
}

- (void)reachableRange:(TTReachableRange *)range completedWithResponseError:(TTResponseError *)responseError {
    [self handleError:responseError];
}

@end
