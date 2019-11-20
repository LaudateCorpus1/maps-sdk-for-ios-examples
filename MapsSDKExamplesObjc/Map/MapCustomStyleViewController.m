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

#import "MapCustomStyleViewController.h"

@implementation MapCustomStyleViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"Basic", @"Custom" ] selectedID:0];
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    switch (ID) {
    case 1:
        [self displayStyleCustom];
        break;
    default:
        [self displayStyleBasic];
        break;
    }
}

#pragma mark Examples

- (void)displayStyleBasic {
    [self.mapView setStylePath:nil];
    [self.mapView applyDefaultLogo];
}

- (void)displayStyleCustom {
    NSString *customStyle = [NSBundle.mainBundle pathForResource:@"style" ofType:@"json"];
    [self.mapView setStylePath:customStyle];
    [self.mapView applyInvertedLogo];
}

@end
