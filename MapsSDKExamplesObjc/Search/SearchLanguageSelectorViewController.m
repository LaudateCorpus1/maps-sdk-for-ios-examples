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

#import "SearchLanguageSelectorViewController.h"
#import <TomTomOnlineSDKSearch/TomTomOnlineSDKSearch.h>

@interface SearchLanguageSelectorViewController () <TTSearchDelegate>
@property(nonatomic, strong) TTSearch *search;
@end

@implementation SearchLanguageSelectorViewController

- (NSInteger)segmentsForControllSelected {
    return 0;
}

- (NSArray<NSString *> *)segmentsForControll {
    return @[ @"🇬🇧 EN", @"🇩🇪 DE", @"🇪🇸 ES", @"🇫🇷 FR" ];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.search = [[TTSearch alloc] initWithKey:Key.Search];
    self.search.delegate = self;
}

- (void)segmentChanged:(UISegmentedControl *)sender {
    [self.searchBar resignFirstResponder];
    if (self.searchBar.text) {
        [self.progress show];
        [self searchForTerm:self.searchBar.text withLanguage:[self languageForIndex:self.segmentedControl.selectedSegmentIndex]];
    }
}

- (void)searchBarFinishedEdittingWith:(NSString *)term {
    [self.progress show];
    [self searchForTerm:term withLanguage:[self languageForIndex:self.segmentedControl.selectedSegmentIndex]];
}

- (NSString *)languageForIndex:(NSInteger)index {
    switch (index) {
    case 3:
        return @"fr-FR";
    case 2:
        return @"es-ES";
    case 1:
        return @"de-DE";
    default:
        return @"en-GB";
    }
}

#pragma mark Example

- (void)searchForTerm:(NSString *)term withLanguage:(NSString *)language {
    TTSearchQuery *query = [[[TTSearchQueryBuilder createWithTerm:term] withLang:language] build];
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
