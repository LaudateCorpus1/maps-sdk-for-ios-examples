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

#import "SearchAddressViewController.h"
#import <TomTomOnlineSDKSearch/TomTomOnlineSDKSearch.h>

@interface SearchAddressViewController () <TTSearchDelegate>
@property(nonatomic, strong) CLLocation *location;
@property(nonatomic, strong) TTSearch *search;
@end

@implementation SearchAddressViewController

- (NSInteger)segmentsForControllSelected {
  return 0;
}

- (NSArray<NSString *> *)segmentsForControll {
  return @[ @"GLOBAL", @"NEAR ME" ];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.search = [TTSearch new];
  self.search.delegate = self;
}

- (void)searchBarFinishedEdittingWith:(NSString *)term {
  [self.progress show];
  if (self.segmentedControl.selectedSegmentIndex == 0) {
    [self searchForTerm:term];
  } else {
    if (!self.location) {
      [self.toast toastWithMessage:@"Location not determined"];
      self.segmentedControl.selectedSegmentIndex = 0;
      [self.progress hide];
      return;
    }
    [self searchForTerm:term at:self.location.coordinate];
  }
}

- (void)segmentChanged:(UISegmentedControl *)sender {
  [self.searchBar resignFirstResponder];
  if (sender.selectedSegmentIndex == 1) {
    self.location = self.locationManager.lastLocation;
  } else {
    self.location = nil;
  }
  NSString *term = self.searchBar.text;
  if (term) {
    [self searchBarFinishedEdittingWith:term];
  }
}

#pragma mark Examples

- (void)searchForTerm:(NSString *)term {
  TTSearchQuery *query = [[TTSearchQueryBuilder createWithTerm:term] build];
  [self.search searchWithQuery:query];
}

- (void)searchForTerm:(NSString *)term at:(CLLocationCoordinate2D)coordinate {
  TTSearchQuery *query = [[[TTSearchQueryBuilder createWithTerm:term]
      withPosition:coordinate] build];
  [self.search searchWithQuery:query];
}

#pragma mark TTSearchDelegate
- (void)search:(TTSearch *)search
    completedWithResponse:(TTSearchResponse *)response {
  [self.progress hide];
  [self displayResults:response.results];
}
- (void)search:(TTSearch *)search failedWithError:(TTResponseError *)error {
  [self handleError:error];
}
@end
