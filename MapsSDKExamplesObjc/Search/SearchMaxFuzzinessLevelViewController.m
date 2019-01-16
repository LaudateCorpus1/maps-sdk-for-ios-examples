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

#import "SearchMaxFuzzinessLevelViewController.h"
#import <TomTomOnlineSDKSearch/TomTomOnlineSDKSearch.h>

@interface SearchMaxFuzzinessLevelViewController() <TTSearchDelegate>
@property (nonatomic, strong) TTSearch *search;
@end

@implementation SearchMaxFuzzinessLevelViewController

- (NSInteger)segmentsForControllSelected {
    return 0;
}

- (NSArray<NSString *> *)segmentsForControll {
    return @[@"Max 1", @"Max 2", @"Max 3"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.search = [TTSearch new];
    self.search.delegate = self;
}

- (void)segmentChanged:(UISegmentedControl *)sender {
    if (!self.locationManager.lastLocation){
        [self.toast toastWithMessage:@"Location not determined"];
        self.segmentedControl.selectedSegmentIndex = 0;
        return;
    }
    
    [self.searchBar resignFirstResponder];
    if(self.searchBar.text) {
        [self.progress show];
        [self searchForTerm:self.searchBar.text withMaxFuzzyLevel:sender.selectedSegmentIndex + 1];
    }
}

- (void)searchBarFinishedEdittingWith:(NSString *)term {
    if (!self.locationManager.lastLocation){
        [self.toast toastWithMessage:@"Location not determined"];
        self.segmentedControl.selectedSegmentIndex = 0;
        return;
    }
    
    [self.progress show];
    [self searchForTerm:term withMaxFuzzyLevel:self.segmentedControl.selectedSegmentIndex + 1];
}

#pragma mark Example

- (void)searchForTerm:(NSString *)term withMaxFuzzyLevel:(NSUInteger)maxFuzzyLevel {
    TTSearchQuery *query = [[[[[TTSearchQueryBuilder createWithTerm:term]
                               withMinFuzzyLevel:1]
                              withMaxFuzzyLevel:maxFuzzyLevel]
                             withPosition:self.locationManager.lastLocation.coordinate]
                            build];
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

@end
