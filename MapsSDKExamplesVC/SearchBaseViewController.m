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

#import "SearchBaseViewController.h"

@implementation SearchBaseViewController

- (BOOL)shouldDisplaySearchBar {
    return YES;
}

- (BOOL)shouldDisplaySegmentedControll {
    return YES;
}

- (NSArray<NSString *>*)segmentsForControll {
    return [NSArray array];
}

- (NSInteger)segmentsForControllSelected {
    return -1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = LocationManager.shared;
    [self.locationManager start];
    
    self.view = [UIView new];
    self.view.backgroundColor = [TTColor White];
    UIStackView *stackView = [UIStackView new];
    stackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:stackView];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 10;
    
    if([self shouldDisplaySearchBar]) {
        UISearchBar *searchBar = [UISearchBar new];
        self.searchBar = searchBar;
        [stackView addArrangedSubview:searchBar];
        searchBar.delegate = self;
        [searchBar becomeFirstResponder];
        searchBar.barStyle = UIBarStyleDefault;
        searchBar.tintColor = [TTColor GreenLight];
        searchBar.backgroundColor = [TTColor White];
        searchBar.barTintColor = [TTColor White];
    }
    
    if([self shouldDisplaySegmentedControll]) {
        UIView *segmentContainer = [UIView new];
        [segmentContainer.heightAnchor constraintEqualToConstant:46].active = YES;
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[self segmentsForControll]];
        self.segmentedControl = segmentedControl;
        [segmentContainer addSubview:segmentedControl];
        segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        [segmentContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[v0]-20-|" options:0 metrics:nil views:@{@"v0": segmentedControl}]];
        [segmentContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[v0]-8-|" options:0 metrics:nil views:@{@"v0": segmentedControl}]];
        segmentedControl.selectedSegmentIndex = [self segmentsForControllSelected];
        [stackView addArrangedSubview:segmentContainer];
        segmentedControl.backgroundColor = [TTColor White];
        segmentedControl.tintColor = [TTColor GreenLight];
        [segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    [stackView addArrangedSubview:self.tableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.locationManager stop];
}

- (void)segmentChanged:(UISegmentedControl *)sender {}

- (void)searchBarFinishedEdittingWith:(NSString *)term {}

- (void)searchBarIsEdittingWith:(NSString *)term {}

#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if(searchBar.text) {
        [searchBar resignFirstResponder];
        [self searchBarFinishedEdittingWith:searchBar.text];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(searchBar.text) {
        [self searchBarIsEdittingWith:searchBar.text];
    }
}

@end
