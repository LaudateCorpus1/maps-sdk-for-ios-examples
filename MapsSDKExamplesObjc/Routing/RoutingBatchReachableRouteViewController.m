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

#import "RoutingBatchReachableRouteViewController.h"
#import <TomTomOnlineSDKRouting/TomTomOnlineSDKRouting.h>
#import "ReachableRangeQueryFactory.h"

@interface RoutingBatchReachableRouteViewController() <TTBatchRouteVisistor, TTBatchRouteResponseDelegate, TTAnnotationDelegate>
@property (nonatomic, strong) TTBatchRoute *batchRoute;
@property (nonatomic, strong) ReachableRangeQueryFactory *queryFactory;
@property (nonatomic, strong) NSMutableArray<TTPolyline*> *polylines;
@property (nonatomic, assign) NSInteger index;
@end

@implementation RoutingBatchReachableRouteViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[] selectedID:-1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.batchRoute = [TTBatchRoute new];
    self.queryFactory = [ReachableRangeQueryFactory new];
    self.polylines = [NSMutableArray new];
    self.mapView.annotationManager.delegate = self;
    self.batchRoute.delegate = self;
    [self requestForBatch];
    [self.etaView updateWithText:@"Touch polyline to see the description..." icon:[UIImage imageNamed:@"info_small"]];
}

- (void)requestForBatch {
    TTBatchRouteQuery *batchQuery = [[[[TTBatchRouteQueryBuilder createReachableRangeQuery:[self.queryFactory createReachableRangeQueryForElectric]]
                                       addReachableRangeQuery:[self.queryFactory createReachableRangeQueryForCombustion]]
                                      addReachableRangeQuery:[self.queryFactory createReachableRangeQueryForElectricLimitTo2Hours]]
                                     build];
    [self.batchRoute batchRouteWithQuery:batchQuery];
    [self.progress show];
}

#pragma mark TTBatchRouteResponseDelegate

- (void)batch:(TTBatchRoute *)route completedWithResponse:(TTBatchRouteResponse *)response {
    [self.progress hide];
    [response visit:self];
    [self.mapView zoomToCoordinatesDataCollection:self.polylines];
}

- (void)batch:(TTBatchRoute *)route failedWithError:(TTResponseError *)responseError {
    [self handleError:responseError];
}

#pragma mark TTBatchRouteVisistor

- (void)visitReachableRange:(TTReachableRangeResponse *)response {
    CLLocationCoordinate2D *coordinates = malloc(sizeof(CLLocationCoordinate2D) * response.result.boundriesCount + 1);
    for (NSInteger i = 0; i < response.result.boundriesCount; i++) {
        coordinates[i] = [response.result boundryAt:i];
    }
    coordinates[response.result.boundriesCount] = [response.result boundryAt:0];
    
    TTPolyline *polyline = [TTPolyline polylineWithCoordinates:coordinates count:response.result.boundriesCount + 1 opacity:1 width:3 color:[self determinePolylineColor:self.index]];
    polyline.tag = [self determinePolylineDescription:self.index];
    [self.mapView.annotationManager addOverlay:polyline];
    self.index++;
    [self.polylines addObject:polyline];
}

#pragma mark TTAnnotationDelegate

- (void)annotationManager:(id<TTAnnotationManager>)manager touchUpPolyline:(TTPolyline *)polyline {
    if(polyline.tag != nil && [polyline.tag isKindOfClass:[NSString class]]) {
        [self.etaView updateWithText:(NSString*)polyline.tag icon:[UIImage imageNamed:@"info_small"]];
    }
}

- (UIColor* )determinePolylineColor:(NSInteger)index {
    switch (index) {
        case 2:
            return TTColor.Black;
        case 1:
            return TTColor.Blue;
        default:
            return TTColor.GreenLight;
    }
}

- (NSString *)determinePolylineDescription:(NSInteger)index {
    switch (index) {
        case 2:
            return @"Electric with power for 2 h";
        case 1:
            return @"Combustion";
        default:
            return @"Electric";
    }
}

@end
