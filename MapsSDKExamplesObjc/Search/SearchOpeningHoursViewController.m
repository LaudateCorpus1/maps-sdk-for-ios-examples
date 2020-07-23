//
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

#import "SearchOpeningHoursViewController.h"
#import "NSArray+NSArray_Map.h"

@import TomTomOnlineSDKSearch;
@import MapsSDKExamplesVC;

@interface SearchOpeningHoursViewController () <TTAnnotationDelegate>
@property(nonatomic, strong) TTSearch *search;
@end

@implementation SearchOpeningHoursViewController

- (TTSearch *)search {
    if (_search == NULL) {
        _search = [[TTSearch alloc] initWithKey:Key.Search];
    }
    return _search;
}

- (void)executeQuery {
    TTSearchQuery *query = [[[[[TTSearchQueryBuilder createWithTerm:@"Petrol station"] withPosition:[TTCoordinate AMSTERDAM]] withLang:@"en-GB"] withOpeningHours:TTOpeningHoursNextSevenDays] build];

    [self.search searchWithQuery:query
                completionHandle:^(TTSearchResponse *_Nullable response, TTResponseError *_Nullable error) {
                  if (response != NULL) {
                      NSArray<SearchResultAnnotation *> *annotations = [[response.results filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TTSearchResult *_Nullable evaluatedObject, NSDictionary<NSString *, id> *_Nullable bindings) {
                                                                                            return evaluatedObject.poi.openingHours != NULL;
                                                                                          }]] map:^id _Nonnull(TTSearchResult *_Nonnull obj) {
                        return [[SearchResultAnnotation alloc] initWithResult:obj];
                      }];

                      [self.mapView.annotationManager addAnnotations:annotations];
                      [self.mapView zoomToAllAnnotations];
                  }
                }];
}

- (void)onMapReady {
    [super onMapReady];
    self.mapView.annotationManager.delegate = self;
    [self executeQuery];
}

- (void)annotationManager:(id<TTAnnotationManager>)manager annotationSelected:(TTAnnotation *)annotation {
    [self.mapView centerOnCoordinate:[annotation coordinate]];
}

- (UIView<TTCalloutView> *)annotationManager:(id<TTAnnotationManager>)manager viewForSelectedAnnotation:(TTAnnotation *)selectedAnnotation {
    SearchResultAnnotation *annotation = (SearchResultAnnotation *)selectedAnnotation;
    if (annotation == NULL) {
        return [[TTCalloutOutlineView alloc] initWithText:@"-"];
    } else {
        NSString *text = [annotation.result.poi.openingHours humanReadableHours];
        NSString *title = [annotation.result.poi name];

        MultiLineCalloutView *contentView = [[MultiLineCalloutView alloc] initWithText:text title:title calloutSize:CGSizeMake(270, 130)];
        return [[TTCalloutOutlineView alloc] initWithUIView:contentView];
    }
}
@end
