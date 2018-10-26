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

#import "RoutingManeuverListViewController.h"
#import <TomTomOnlineSDKRouting/TomTomOnlineSDKRouting.h>

@interface RoutingManeuverListViewController() <TTRouteResponseDelegate>
@property (nonatomic, strong) LocationManager *locationManager;
@property (nonatomic, strong) ETAWithSegmentsView *etaView;
@property (nonatomic, strong) TTRoute *routePlanner;
@end

@implementation RoutingManeuverListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = LocationManager.shared;
    [self.locationManager start];
    self.routePlanner = [TTRoute new];
    self.routePlanner.delegate = self;
    ETAWithSegmentsView *etaView = [[ETAWithSegmentsView alloc] initWithFrame:CGRectMake(0, 0, 0, 80)];
    self.etaView = etaView;
    etaView.segments.selectedSegmentIndex = 0;
    self.tableView.rowHeight = 70;
    self.tableView.tableHeaderView = etaView;
    [etaView addTarget:self action:@selector(languageChanged:)];
    [self displayManeuverList:TTLanguageEnglishGB];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.locationManager stop];
}

- (void)languageChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 3:
            [self displayManeuverList:TTLanguageGerman];
            break;
        case 2:
            [self displayManeuverList:TTLanguageSpanishES];
            break;
        case 1:
            [self displayManeuverList:TTLanguageFrenchFR];
            break;
        default:
            [self displayManeuverList:TTLanguageEnglishGB];
            break;
    }
}

- (void)displayManeuverList:(TTLanguage)language {
    [self.progress show];
    TTRouteQuery *query = [[[[TTRouteQueryBuilder createWithDest:[TTCoordinate BERLIN] andOrig:[TTCoordinate AMSTERDAM]]
                             withInstructionsType:TTOptionInstructionsTypeText]
                            withLanguage:language]
                           build];
    [self.routePlanner planRouteWithQuery:query];
}

#pragma mark TTRouteResponseDelegate

- (void)route:(TTRoute *)route completedWithResult:(TTRouteResult *)result {
    TTFullRoute *plannedRoute = result.routes.firstObject;
    if(!plannedRoute) {
        return;
    }
    [self.etaView showWithSummary:plannedRoute.summary];
    [self displayResults:plannedRoute.guidance.instructions];
    [self.progress hide];
}

- (void)route:(TTRoute *)route completedWithResponseError:(TTResponseError *)responseError {
    [self.toast toastWithMessage:[NSString stringWithFormat:@"error %@", responseError.userInfo[@"description"]]];
    [self.progress hide];
}

@end
