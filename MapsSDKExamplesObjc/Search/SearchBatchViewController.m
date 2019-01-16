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

#import "SearchBatchViewController.h"
#import <TomTomOnlineSDKSearch/TomTomOnlineSDKSearch.h>

@interface SearchBatchViewController() <TTBatchSearchDelegate, TTBatchVisistor>
@property (nonatomic, strong) TTBatchSearch *batchSearch;
@end

@implementation SearchBatchViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[@"Bar", @"Gas", @"Parking"] selectedID:-1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.batchSearch = [TTBatchSearch new];
    self.batchSearch.delegate = self;
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    [self.mapView.annotationManager removeAllOverlays];
    [self.mapView.annotationManager removeAllAnnotations];
    [self.progress show];
    switch (ID) {
        case 2:
            [self batchSearchWithTerm:@"Bar"];
            break;
        case 1:
            [self batchSearchWithTerm:@"Gas"];
            break;
        default:
            [self batchSearchWithTerm:@"Parking"];
            break;
    }
}

#pragma mark Examples

- (void)batchSearchWithTerm:(NSString *)term {
    TTSearchQuery *query1 = [[[[[TTSearchQueryBuilder createWithTerm:term] withCategory:YES]
                               withPosition:[TTCoordinate AMSTERDAM_CENTER_LOCATION]]
                              withLimit:10]
                             build];
    TTSearchQuery *query2 = [[[[[TTSearchQueryBuilder createWithTerm:term] withCategory:YES]
                               withPosition:[TTCoordinate HAARLEM]]
                              withLimit:15]
                             build];
    TTSearchCircle *geometry = [TTSearchCircle circleWithCenter:[TTCoordinate HOOFDDORP] radius:4000];
    TTGeometrySearchQuery *geometryQuery = [[TTGeometrySearchQueryBuilder createWithTerm:term searchShapes:@[geometry]]
                                            build];
    TTBatchQuery *batchQuery = [[[[TTBatchQueryBuilder createSearchQuery:query1]
                                  addSearchQuery:query2]
                                 addGeometryQuery:geometryQuery]
                                build];
    [self.batchSearch batchSearchWithQuery:batchQuery];
}

#pragma mark TTBatchSearchDelegate

- (void)batch:(TTBatchSearch *)batch completedWithResponse:(TTBatchResponse *)response {
    [self.progress hide];
    [response visit:self];
}

- (void)batch:(TTBatchSearch *)batch failedWithError:(TTResponseError *)error {
    [self handleError:error];
}

#pragma mark TTBatchVisistor

- (void)visitSearch:(TTSearchResponse *)response {
    for (TTSearchResult *result in response.results) {
        TTAnnotation *annotation = [TTAnnotation annotationWithCoordinate:result.position];
        [self.mapView.annotationManager addAnnotation:annotation];
    }
}

- (void)visitGeometrySearch:(TTGeometrySearchResponse *)response {
    for (TTSearchResult *result in response.results) {
        TTAnnotation *annotation = [TTAnnotation annotationWithCoordinate:result.position];
        [self.mapView.annotationManager addAnnotation:annotation];
    }
    
    TTCircle *circle = [TTCircle circleWithCenterCoordinate:[TTCoordinate HOOFDDORP] radius:4000 width:2 color:[TTColor RedSemiTransparent] fill:YES colorOutlet:[TTColor RedSemiTransparent]];
    [self.mapView.annotationManager addOverlay:circle];
    
    [self.mapView zoomToAllAnnotations];
}

@end
