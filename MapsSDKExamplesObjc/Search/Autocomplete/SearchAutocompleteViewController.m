//
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

#import "SearchAutocompleteViewController.h"
#import "NSArray+NSArray_Map.h"
#import "TTAutocompleteSegment+TTAutocompleteSegment_Helpers.h"

@import TomTomOnlineSDKSearch;
@import MapsSDKExamplesCommon;
@import TomTomOnlineSDKMaps;

@interface SearchAutocompleteViewController () <AutoCompleteBarDelegate, TTAnnotationDelegate>
@property(nonatomic) AutoCompleteBar *bar;
@property(nonatomic) TTMapView *mapView;
@property(nonatomic) TTAutocomplete *autocomplete;
@property(nonatomic) TTSearch *search;

@end

@implementation SearchAutocompleteViewController

- (AutoCompleteBar *)bar {
    if (_bar == NULL) {
        _bar = [[AutoCompleteBar alloc] init];
        _bar.delegate = self;
    }
    return _bar;
}

- (TTSearch *)search {
    if (_search == NULL) {
        _search = [[TTSearch alloc] init];
    }
    return _search;
}

- (TTAutocomplete *)autocomplete {
    if (_autocomplete == NULL) {
        _autocomplete = [[TTAutocomplete alloc] init];
    }
    return _autocomplete;
}

- (TTMapView *)mapView {
    if (_mapView == NULL) {
        TTMapConfigurationBuilder *configBuilder = [TTMapConfigurationBuilder createBuilder];
        TTCenterOnPointBuilder *transformBuilder = [[TTCenterOnPointBuilder createWithCenter:[TTCoordinate AMSTERDAM]] withZoom:9];
        [configBuilder withViewportTransform:[transformBuilder build]];
        _mapView = [[TTMapView alloc] initWithFrame:CGRectZero mapConfiguration:[configBuilder build]];
        _mapView.translatesAutoresizingMaskIntoConstraints = NO;
        _mapView.annotationManager.delegate = self;
    }
    return _mapView;
}

- (void)loadView {
    [super loadView];
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.bar];

    CGFloat topOffset = 50;

    if (@available(iOS 11.0, *)) {
        [[self.bar.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor] setActive:YES];
        [[self.mapView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:topOffset] setActive:YES];
    } else {
        [[self.bar.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
        [[self.mapView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:topOffset] setActive:YES];
    }

    [[self.mapView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor] setActive:YES];
    [[self.mapView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor] setActive:YES];
    [[self.mapView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    [[self.bar.leftAnchor constraintEqualToAnchor:self.view.leftAnchor] setActive:YES];
    [[self.bar.rightAnchor constraintEqualToAnchor:self.view.rightAnchor] setActive:YES];
}

#pragma mark AutoCompleteBarDelegate

- (void)autoCompleteBarCancelButtonClickedWithBar:(AutoCompleteBar *_Nonnull)bar {
    bar.data = [[NSArray alloc] init];
}

- (void)autoCompleteBarWithBar:(AutoCompleteBar *_Nonnull)bar didSelect:(id<AutoCompleteBarModel> _Nonnull)item withText:(NSString *_Nonnull)text {

    TTAutocompleteSegment *segment = (TTAutocompleteSegment *)item;
    if (segment != NULL) {
        NSString *searchTerm = segment.title;
        TTSearchQueryBuilder *builder = [TTSearchQueryBuilder createWithTerm:searchTerm];
        builder = [builder withPosition:[TTCoordinate AMSTERDAM] withRadius:10000];

        switch (segment.type) {
        case TTSegmentTypeBrand:
            [builder withBrandSet:searchTerm];
            break;
        case TTSegmentTypeCategory:
            [builder withCategory:YES];
            break;
        default:
            break;
        }

        __weak SearchAutocompleteViewController *weakSelf = self;

        [self.search searchWithQuery:[builder build]
                    completionHandle:^(TTSearchResponse *_Nullable response, TTResponseError *_Nullable error) {
                      SearchAutocompleteViewController *strongSelf = weakSelf;

                      if (strongSelf != NULL && response != NULL) {
                          NSArray<SearchResultAnnotation *> *result = [response.results map:^id _Nonnull(TTSearchResult *_Nonnull obj) {
                            return [[SearchResultAnnotation alloc] initWithResult:obj];
                          }];

                          self.bar.data = [NSArray new];

                          [self.mapView.annotationManager removeAllAnnotations];
                          [self.mapView.annotationManager addAnnotations:result];
                          [self.mapView zoomToAnnotations:result];
                      }
                    }];
    }
}

- (void)autoCompleteBarWithBar:(AutoCompleteBar *_Nonnull)bar textDidChange:(NSString *_Nonnull)text {

    TTAutocompleteQueryBuilder *builder = [TTAutocompleteQueryBuilder createWithTerm:text withLanguage:@"en-GB"];
    TTAutocompleteQuery *query = [[[[builder withCountry:@"NL"] withLimit:10] withResultType:TTResultEmpty] build];

    __weak SearchAutocompleteViewController *weakSelf = self;

    [self.autocomplete requestWithQuery:query
                       completionHandle:^(TTAutocompleteResponse *_Nullable response, TTResponseError *_Nullable error) {
                         SearchAutocompleteViewController *strongSelf = weakSelf;

                         if (strongSelf != NULL && response != NULL) {

                             NSArray<TTAutocompleteSegment *> *data = [[response.results map:^id _Nonnull(TTAutocompleteResult *_Nonnull obj) {
                               return obj.segments;
                             }] flatMap:^id _Nonnull(NSArray<TTAutocompleteSegment *> *_Nonnull obj) {
                               return obj;
                             }];

                             self.bar.data = data;
                         }
                       }];
}

#pragma mark TTAnnotationDelegate

- (UIView<TTCalloutView> *)annotationManager:(id<TTAnnotationManager>)manager viewForSelectedAnnotation:(TTAnnotation *)selectedAnnotation {
    SearchResultAnnotation *annotation = (SearchResultAnnotation *)selectedAnnotation;
    if (annotation == NULL) {
        return [[TTCalloutOutlineView alloc] initWithText:@"-"];
    } else {
        NSString *text = annotation.result.poi.name ? annotation.result.poi.name : @"-";
        return [[TTCalloutOutlineView alloc] initWithText:text];
    }
}

@end
