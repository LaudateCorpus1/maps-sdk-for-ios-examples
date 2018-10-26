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

#import "SearchAdditionalDataViewController.h"
#import <TomTomOnlineSDKSearch/TomTomOnlineSDKSearch.h>

@interface PolygonAdditionalDataVisitior : NSObject <TTADPGeoJsonObjectVisitor, TTADPGeoJsonGeoVisitor>
@property (nonatomic, strong) NSMutableArray<TTADPLineString *> *lineStrings;
@end

@implementation PolygonAdditionalDataVisitior

- (instancetype)init {
    self = [super init];
    if(self) {
        self.lineStrings = [NSMutableArray new];
    }
    return self;
}

- (void)visitFeatureCollection:(TTADPFeatureCollection *)featureCollection {
    for (TTADPFeature *feature in featureCollection.features) {
        [feature visitResult:self];
    }
}

- (void)visitPolygon:(TTADPPolygon *)polygon {
    [self.lineStrings addObject:polygon.exteriorRing];
}

- (void)visitMultiPolygon:(TTADPMultiPolygon *)multiPolygon {
    for (TTADPPolygon *polygon in multiPolygon.polygons) {
        [self.lineStrings addObject:polygon.exteriorRing];
    }
}

@end

@interface SearchAdditionalDataViewController() <TTSearchDelegate, TTAdditionalDataSearchDelegate>
@property (nonatomic, strong) TTSearch *search;
@property (nonatomic, strong) TTAdditionalDataSearch *searchAdditionalData;
@end

@implementation SearchAdditionalDataViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[@"Amsterdam", @"Berlin", @"Poland"] selectedID:-1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.search = [TTSearch new];
    self.search.delegate = self;
    self.searchAdditionalData = [TTAdditionalDataSearch new];
    self.searchAdditionalData.delegate = self;
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    [self.mapView.routeManager removeAllRoutes];
    [self.progress show];
    switch (ID) {
        case 2:
            [self displayAdditionalDataPoland];
            break;
        case 1:
            [self displayAdditionalDataBerlin];
            break;
        default:
            [self displayAdditionalDataAmsterdam];
            break;
    }
}

#pragma mark Examples

- (void)displayAdditionalDataAmsterdam {
    TTSearchQuery *query = [[[TTSearchQueryBuilder createWithTerm:@"Amsterdam"]
                             withIdxSet:TTSearchIndexGeographies]
                            build];
    [self.search searchWithQuery:query];
}

- (void)displayAdditionalDataBerlin {
    TTSearchQuery *query = [[[TTSearchQueryBuilder createWithTerm:@"Berlin"]
                             withIdxSet:TTSearchIndexGeographies]
                            build];
    [self.search searchWithQuery:query];
}

- (void)displayAdditionalDataPoland {
    TTSearchQuery *query = [[[TTSearchQueryBuilder createWithTerm:@"Poland"]
                             withIdxSet:TTSearchIndexGeographies]
                            build];
    [self.search searchWithQuery:query];
}

#pragma mark TTSearchDelegate
- (void)search:(TTSearch *)search completedWithResponse:(TTSearchResponse *)response {
    TTSearchResult *result = response.results.firstObject;
    if(!result) {
        return;
    }
    TTAdditionalDataSources *additionalData = result.additionalDataSources;
    if(!additionalData) {
        return;
    }
    TTGeometryDataSource *geometryData = additionalData.geometryDataSource;
    if(!geometryData) {
        return;
    }
    TTAdditionalDataSearchQuery *query = [[TTAdditionalDataSearchQueryBuilder createWithDataSource:geometryData]
                                          build];
    [self.searchAdditionalData additionalDataSearchWithQuery:query];
}

- (void)search:(TTSearch *)search failedWithError:(TTResponseError *)error {
    [self.toast toastWithMessage:[NSString stringWithFormat:@"error %@", error.userInfo[@"description"]]];
    [self.progress hide];
    [self.optionsView deselectAll];
}

#pragma mark TTAdditionalDataSearchDelegate
- (void)additionalDataSearch:(TTAdditionalDataSearch *)additionalDataSearch completedWithResponse:(TTAdditionalDataSearchResponse *)response {
    [self.progress hide];
    TTAdditionalDataSearchResult *result = response.results.firstObject;
    if(!result) {
        return;
    }
    PolygonAdditionalDataVisitior *visitor = [PolygonAdditionalDataVisitior new];
    [result visitResult:visitor];
    NSMutableArray<TTPolygon *>* mapPolygons = [NSMutableArray new];
    for (TTADPLineString *lineString in visitor.lineStrings) {
        TTPolygon *mapPolygon = [TTPolygon polygonWithCoordinatesData:lineString opacity:0.7 color:[TTColor Red] colorOutline:[TTColor Red]];
        [mapPolygons addObject:mapPolygon];
        [self.mapView.annotationManager addOverlay:mapPolygon];
    }
    [self.mapView zoomToCoordinatesDataCollection:mapPolygons];
}

- (void)additionalDataSearch:(TTAdditionalDataSearch *)additionalDataSearch failedWithError:(TTResponseError *)error {
    [self.toast toastWithMessage:[NSString stringWithFormat:@"error %@", error.userInfo[@"description"]]];
    [self.progress hide];
    [self.optionsView deselectAll];
}

@end
