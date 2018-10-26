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

#import "ButtonsBaseViewController.h"

@implementation ButtonsBaseViewController

- (void)setupControls {
    OptionsView *optionsView = [self getOptionsView];
    self.optionsView = optionsView;
    optionsView.delegate = self;
    [self.view addSubview:optionsView];
    optionsView.translatesAutoresizingMaskIntoConstraints = NO;
    [optionsView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-20].active = YES;
    [optionsView.heightAnchor constraintEqualToConstant:36].active = YES;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[v0]-20-|" options:0 metrics:nil views:@{@"v0": optionsView}]];
}

- (OptionsView *)getOptionsView {
    return [[OptionsView alloc] initWithLabels:@[] selectedID:-1];
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {}

@end
