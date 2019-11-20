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

#import "SearchTypeaheadParameterViewController.h"
#import <TomTomOnlineSDKSearch/TomTomOnlineSDKSearch.h>

@interface SearchTypeaheadParameterViewController () <TTSearchDelegate>
@property(nonatomic, strong) TTSearch *search;
@end

@implementation SearchTypeaheadParameterViewController

- (BOOL)shouldDisplaySegmentedControll {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.search = [TTSearch new];
    self.search.delegate = self;
}

- (void)searchBarIsEdittingWith:(NSString *)term {
    [self searchForTermWithTypeahead:term];
}

#pragma mark Example

- (void)searchForTermWithTypeahead:(NSString *)term {
    TTSearchQuery *query = [[[TTSearchQueryBuilder createWithTerm:term] withTypeAhead:YES] build];
    [self.search searchWithQuery:query];
}

#pragma mark TTSearchDelegate

- (void)search:(TTSearch *)search completedWithResponse:(TTSearchResponse *)response {
    [self.progress hide];
    [self displayResults:response.results];
}

- (void)search:(TTSearch *)search failedWithError:(TTResponseError *)error {
    [self handleError:error];
}
- (void)cancelSearch {
    [self.search cancel];
}
@end
