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

#import "SearchGeometryViewController.h"
#import <TomTomOnlineSDKSearch/TomTomOnlineSDKSearch.h>
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>

@interface SearchGeometryViewController () <TTGeometrySearchDelegate>
@property(nonatomic, strong) TTGeometrySearch *geometrySearch;
@property(nonatomic, strong) NSMutableArray<TTSearchShape *> *geometryShape;
@end

@implementation SearchGeometryViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"Parking", @"ATM", @"Grocery" ] selectedID:-1];
}

- (void)setupInitialCameraPosition {
    [self.mapView centerOnCoordinate:[TTCoordinate AMSTERDAM_A10] withZoom:10];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.geometrySearch = [[TTGeometrySearch alloc] initWithKey:Key.Search];
    self.geometryShape = [NSMutableArray array];
    [self createShapesForSearch];
    self.geometrySearch.delegate = self;
}

- (void)createShapesForSearch {
    CLLocationCoordinate2D coordinates[13];
    coordinates[0] = CLLocationCoordinate2DMake(52.37874, 4.90482);
    coordinates[1] = CLLocationCoordinate2DMake(52.37664, 4.92559);
    coordinates[2] = CLLocationCoordinate2DMake(52.37497, 4.94877);
    coordinates[3] = CLLocationCoordinate2DMake(52.36805, 4.97246);
    coordinates[4] = CLLocationCoordinate2DMake(52.34918, 4.95993);
    coordinates[5] = CLLocationCoordinate2DMake(52.34016, 4.95169);
    coordinates[6] = CLLocationCoordinate2DMake(52.32894, 4.91392);
    coordinates[7] = CLLocationCoordinate2DMake(52.34048, 4.88611);
    coordinates[8] = CLLocationCoordinate2DMake(52.33953, 4.84388);
    coordinates[9] = CLLocationCoordinate2DMake(52.37067, 4.8432);
    coordinates[10] = CLLocationCoordinate2DMake(52.38492, 4.84663);
    coordinates[11] = CLLocationCoordinate2DMake(52.40011, 4.85058);
    coordinates[12] = CLLocationCoordinate2DMake(52.38995, 4.89075);
    TTPolygon *mapPolygon = [TTPolygon polygonWithCoordinates:coordinates count:13 opacity:1 color:[TTColor RedSemiTransparent] colorOutline:[TTColor RedSemiTransparent]];
    [self.mapView.annotationManager addOverlay:mapPolygon];
    [self.geometryShape addObject:[TTSearchPolygon polygonWithCoordinates:coordinates count:13]];

    TTCircle *mapCircle = [TTCircle circleWithCenterCoordinate:[TTCoordinate AMSTERDAM_CIRCLE] radius:2000 width:2 color:[TTColor RedSemiTransparent] fill:YES colorOutlet:[TTColor RedSemiTransparent]];
    [self.mapView.annotationManager addOverlay:mapCircle];
    [self.geometryShape addObject:[TTSearchCircle circleWithCenter:[TTCoordinate AMSTERDAM_CIRCLE] radius:2000]];
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    [self.progress show];
    [self.mapView.annotationManager removeAllAnnotations];
    switch (ID) {
    case 2:
        [self searchForGrocery];
        break;
    case 1:
        [self searchForATM];
        break;
    default:
        [self searchForParking];
        break;
    }
}

#pragma mark Examples

- (void)searchForParking {
    TTGeometrySearchQuery *query = [[[TTGeometrySearchQueryBuilder createWithTerm:@"Parking" searchShapes:self.geometryShape] withLimit:30] build];
    [self.geometrySearch searchWithQuery:query];
}

- (void)searchForATM {
    TTGeometrySearchQuery *query = [[[TTGeometrySearchQueryBuilder createWithTerm:@"ATM" searchShapes:self.geometryShape] withLimit:30] build];
    [self.geometrySearch searchWithQuery:query];
}

- (void)searchForGrocery {
    TTGeometrySearchQuery *query = [[[TTGeometrySearchQueryBuilder createWithTerm:@"Grocery" searchShapes:self.geometryShape] withLimit:30] build];
    [self.geometrySearch searchWithQuery:query];
}

#pragma mark TTGeometrySearchDelegate

- (void)search:(TTGeometrySearch *)search completedWithResponse:(TTGeometrySearchResponse *)response {
    [self.progress hide];
    for (TTGeometrySearchResult *result in response.results) {
        TTAnnotation *annotation = [TTAnnotation annotationWithCoordinate:result.position];
        [self.mapView.annotationManager addAnnotation:annotation];
    }
}

- (void)search:(TTGeometrySearch *)search failedWithError:(TTResponseError *)error {
    [self handleError:error];
}

@end
