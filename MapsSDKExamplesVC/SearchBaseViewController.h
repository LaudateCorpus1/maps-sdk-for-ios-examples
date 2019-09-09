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

#import <UIKit/UIKit.h>
#import <MapsSDKExamplesCommon/MapsSDKExamplesCommon-Swift.h>
#import "TableBaseViewController.h"

@interface SearchBaseViewController
    : TableBaseViewController <UISearchBarDelegate>
@property(nonatomic, strong) LocationManager *_Nonnull locationManager;
@property(nonatomic, weak) UISearchBar *_Nullable searchBar;
@property(nonatomic, weak) UISegmentedControl *_Nullable segmentedControl;
- (BOOL)shouldDisplaySearchBar;
- (BOOL)shouldDisplaySegmentedControll;
- (NSArray<NSString *> *_Nonnull)segmentsForControll;
- (NSInteger)segmentsForControllSelected;
- (void)segmentChanged:(UISegmentedControl *_Nonnull)sender;
- (void)searchBarFinishedEdittingWith:(NSString *_Nonnull)term;
- (void)searchBarIsEdittingWith:(NSString *_Nonnull)term;
@end
