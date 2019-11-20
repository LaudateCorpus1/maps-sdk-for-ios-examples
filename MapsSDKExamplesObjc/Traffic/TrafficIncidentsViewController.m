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

#import "TrafficIncidentsViewController.h"
#import <TomTomOnlineSDKTraffic/TomTomOnlineSDKTraffic.h>

@interface TrafficIncidentsViewController () <TTTrafficIncidentsDelegate>
@property(nonatomic, strong) TTTrafficIncidents *traffic;
@end

@implementation TrafficIncidentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.traffic = [TTTrafficIncidents new];
    self.traffic.delegate = self;
    [self displayIncidents];
}

#pragma mark Example

- (void)displayIncidents {
    [self.progress show];
    TTLatLngBounds bounds = TTLatLngBoundsMake([TTCoordinate LONDON_TOP_LEFT], [TTCoordinate LONDON_BOTTOM_RIGHT]);
    TTIncidentDetailsQuery *query = [[TTIncidentDetailsQueryBuilder createWithStyle:TTTrafficIncidentStyleTypeS1 withBoundingBox:bounds withZoom:12 withTrafficModelID:@"-1"] build];
    [self.traffic incidentDetailsWithQuery:query];
}

#pragma mark TTTrafficIncidentsDelegate

- (void)incidentDetails:(TTTrafficIncidents *)trafficIncidents completedWithResponse:(TTIncidentDetailsResponse *)response {
    [self.progress hide];
    [self displayResults:response.incidents];
}

- (void)incidentDetails:(TTTrafficIncidents *)trafficIncidents failedWithError:(TTResponseError *)error {
    [self handleError:error];
}

@end
