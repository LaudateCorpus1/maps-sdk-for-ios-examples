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

#import "SearchEntryPointsViewController.h"
#import <TomTomOnlineSDKSearch/TomTomOnlineSDKSearch.h>

@interface SearchEntryPointsViewController() <TTSearchDelegate>
@property (nonatomic, strong) TTSearch *search;
@end

@implementation SearchEntryPointsViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[@"Airport", @"Shopping Mall"] selectedID:-1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.search = [TTSearch new];
    self.search.delegate = self;
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    [self.progress show];
    [self.mapView.annotationManager removeAllAnnotations];
    switch (ID) {
        case 1:
            [self displayEntryPointsForShoppingMall];
            break;
        default:
            [self displayEntryPointsForAirport];
            break;
    }
}

#pragma mark Examples

- (void)displayEntryPointsForAirport {
    TTSearchQuery *query = [[TTSearchQueryBuilder createWithTerm:@"Amsterdam Airport Schiphol"]
                            build];
    [self.search searchWithQuery:query];
}

- (void)displayEntryPointsForShoppingMall {
    TTSearchQuery *query = [[TTSearchQueryBuilder createWithTerm:@"Kalvertoren Singel 451"]
                            build];
    [self.search searchWithQuery:query];
}

#pragma mark TTSearchDelegate

- (void)search:(TTSearch *)search completedWithResponse:(TTSearchResponse *)response {
    [self.progress hide];
    TTSearchResult *result = response.results.firstObject;
    if(!result) {
        return;
    }
    NSArray<TTEntryPoint*> *entryPoints = result.entryPoints;
    if(!entryPoints) {
        return;
    }
    
    TTAnnotation *annotation = [TTAnnotation annotationWithCoordinate:result.position];
    [self.mapView.annotationManager addAnnotation:annotation];
    for (TTEntryPoint *entryPoint in entryPoints) {
        TTAnnotation *annotation = [TTAnnotation annotationWithCoordinate:entryPoint.position annotationImage:[TTAnnotationImage createPNGWithName:@"entry_point"] anchor:TTAnnotationAnchorBottom type:TTAnnotationTypeFocal];
        [self.mapView.annotationManager addAnnotation:annotation];
    }
    [self.mapView zoomToAllAnnotations];
}

- (void)search:(TTSearch *)search failedWithError:(TTResponseError *)error {
    [self.toast toastWithMessage:[NSString stringWithFormat:@"error %@", error.userInfo[@"description"]]];
    [self.progress hide];
    [self.optionsView deselectAll];
}

@end
