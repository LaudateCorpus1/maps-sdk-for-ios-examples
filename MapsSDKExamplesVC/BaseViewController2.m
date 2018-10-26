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

#import "BaseViewController.h"

@implementation BaseViewController

- (instancetype)init {
    self = [super init];
    if(self) {
        self.name = @"TomTom SDK Example";
        self.toast = [[Toast alloc] init];
        self.progress = [[Progress alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    [self setupNavigationBar];
}

- (void)setupNavigationBar {
    self.navigationItem.title = self.name;
    self.navigationController.navigationBar.barTintColor = [TTColor BlackLight];
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [TTColor White]};
}

@end
