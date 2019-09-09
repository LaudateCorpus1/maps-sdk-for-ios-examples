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

#import "TrafficBaseViewController.h"

@implementation TrafficBaseViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.rowHeight = 70;
  self.tableView.delegate = self;
}

- (UIView *)tableView:(UITableView *)tableView
    viewForHeaderInSection:(NSInteger)section {
  return [[NSBundle bundleForClass:[TrafficBaseViewController class]]
             loadNibNamed:@"TrafficHeader"
                    owner:self
                  options:nil]
      .firstObject;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
  return 40;
}

@end
