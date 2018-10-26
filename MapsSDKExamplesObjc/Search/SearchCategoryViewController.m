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

#import "SearchCategoryViewController.h"
#import <TomTomOnlineSDKSearch/TomTomOnlineSDKSearch.h>

@interface SearchCategoryViewController() <TTSearchDelegate>
@property (nonatomic, strong) TTSearch *search;
@end

@implementation SearchCategoryViewController

- (BOOL)shouldDisplaySearchBar {
    return NO;
}

- (NSInteger)segmentsForControllSelected {
    return -1;
}

- (NSArray<NSString *> *)segmentsForControll {
    return @[@"PARKING", @"GAS", @"ATM"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.search = [TTSearch new];
    self.search.delegate = self;
}

- (void)segmentChanged:(UISegmentedControl *)sender {
    if(!self.locationManager.lastLocation) {
        [self.toast toastWithMessage:@"Location not determined"];
        self.segmentedControl.selectedSegmentIndex = -1;
        [self.progress hide];
        return;
    }
    [self.progress show];
    switch (sender.selectedSegmentIndex) {
        case 2:
            [self searchCategoryATM];
            break;
        case 1:
            [self searchCategoryGas];
            break;
        default:
            [self searchCategoryParking];
            break;
    }
}

#pragma mark Examples

- (void)searchCategoryParking {
    TTSearchQuery *query = [[[[TTSearchQueryBuilder createWithTerm:@"parking"]
                              withCategory:YES]
                             withPosition:self.locationManager.lastLocation.coordinate]
                            build];
    [self.search searchWithQuery:query];
}

- (void)searchCategoryGas {
    TTSearchQuery *query = [[[[TTSearchQueryBuilder createWithTerm:@"gas"]
                              withCategory:YES]
                             withPosition:self.locationManager.lastLocation.coordinate]
                            build];
    [self.search searchWithQuery:query];
}

- (void)searchCategoryATM {
    TTSearchQuery *query = [[[[TTSearchQueryBuilder createWithTerm:@"atm"]
                              withCategory:YES]
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
    [self.toast toastWithMessage:[NSString stringWithFormat:@"error %@", error.userInfo[@"description"]]];
    [self.progress hide];
}

@end
