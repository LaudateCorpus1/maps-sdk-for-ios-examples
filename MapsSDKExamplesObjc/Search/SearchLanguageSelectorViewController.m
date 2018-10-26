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

#import "SearchLanguageSelectorViewController.h"
#import <TomTomOnlineSDKSearch/TomTomOnlineSDKSearch.h>

@interface SearchLanguageSelectorViewController() <TTSearchDelegate>
@property (nonatomic, strong) TTSearch *search;
@end

@implementation SearchLanguageSelectorViewController

- (NSInteger)segmentsForControllSelected {
    return 0;
}

- (NSArray<NSString *> *)segmentsForControll {
    return @[@"🇬🇧 EN", @"🇩🇪 DE", @"🇪🇸 ES", @"🇫🇷 FR"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.search = [TTSearch new];
    self.search.delegate = self;
}

- (void)segmentChanged:(UISegmentedControl *)sender {
    [self.searchBar resignFirstResponder];
    if(self.searchBar.text) {
        [self.progress show];
        [self searchForTerm:self.searchBar.text withLanguage:[self languageForIndex:self.segmentedControl.selectedSegmentIndex]];
    }
}

- (void)searchBarFinishedEdittingWith:(NSString *)term {
    [self.progress show];
    [self searchForTerm:term withLanguage:[self languageForIndex:self.segmentedControl.selectedSegmentIndex]];
}

- (TTLanguage)languageForIndex:(NSInteger)index {
    switch (index) {
        case 3:
            return TTLanguageFrenchFR;
        case 2:
            return TTLanguageSpanishES;
        case 1:
            return TTLanguageGerman;
        default:
            return TTLanguageEnglishGB;
    }
}

#pragma mark Example

- (void)searchForTerm:(NSString *)term withLanguage:(TTLanguage)language {
    TTSearchQuery *query = [[[TTSearchQueryBuilder createWithTerm:term]
                             withLanguage:language]
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
