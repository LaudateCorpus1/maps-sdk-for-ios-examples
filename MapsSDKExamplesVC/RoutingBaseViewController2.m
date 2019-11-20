/**
 * Copyright (c) 2018 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its
 * subsidiaries and may be used for internal evaluation purposes or commercial
 * use strictly subject to separate licensee agreement between you and TomTom.
 * If you are the licensee, you are only permitted to use this Software in
 * accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and
 * should immediately return it to TomTom N.V.
 */

#import "RoutingBaseViewController.h"

@implementation RoutingBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupEtaView];
}

- (void)setupCenterOnWillHappen {
    [self.mapView centerOnCoordinate:[TTCoordinate ALPHEN_AAN_DEN_RIJN] withZoom:8.5];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator
        animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        }
        completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
          [self.mapView.routeManager showAllRoutesOverview];
        }];
}

- (void)setupEtaView {
    ETAView *etaView = [ETAView new];
    [self.view addSubview:etaView];
    self.etaView = etaView;
    etaView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[v0]-0-|" options:0 metrics:nil views:@{@"v0" : etaView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[v0(50)]" options:0 metrics:nil views:@{@"v0" : etaView}]];
}

- (void)showETA:(TTSummary *)summary {
    [self.etaView showWithSummary:summary style:ETAViewStylePlain];
}

- (void)hideEta {
    [self.etaView hide];
}

- (void)displayRouteOverview {
    UIEdgeInsets insets = UIEdgeInsetsMake(30 * UIScreen.mainScreen.scale, 10 * UIScreen.mainScreen.scale, 30 * UIScreen.mainScreen.scale, 10 * UIScreen.mainScreen.scale);
    self.mapView.contentInset = insets;
    [self.mapView.routeManager showAllRoutesOverview];
}

@end
